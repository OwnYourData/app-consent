class PagesController < ApplicationController
    include ApplicationHelper

    def index
        start_ts = Time.now.to_i
        pia_url = params[:PIA_URL].to_s
        if pia_url.to_s == ""
            pia_url = session[:pia_url]
            if pia_url.to_s == ""
                pia_url = cookies.signed[:pia_url]
            end
        else
            session[:pia_url] = pia_url
        end

        app_key = params[:APP_KEY].to_s
        if app_key.to_s == ""
            app_key = session[:app_key]
            if app_key.to_s == ""
                app_key = cookies.signed[:app_key]
            end
        else
            session[:app_key] = app_key
        end

        app_secret = params[:APP_SECRET].to_s
        if app_secret.to_s == ""
            app_secret = session[:app_secret]
            if app_secret.to_s == ""
                app_secret = cookies.signed[:app_secret]
            end
        else
            session[:app_secret] = app_secret
        end

        desktop = params[:desktop].to_s
        if desktop == ""
            desktop = session[:desktop]
            if desktop == ""
                desktop = false
            else
                if desktop == "1"
                    desktop = true
                else
                    desktop = false
                end
            end
        else
            if desktop == "1"
                desktop = true
            else
                desktop = false
            end
        end
        if desktop
            session[:desktop] = "1"
        else
            session[:desktop] = "0"
        end

        nonce = params[:NONCE].to_s
        if nonce.to_s == ""
            nonce = session[:nonce].to_s
            if nonce.to_s == ""
                nonce = cookies.signed[:nonce].to_s
            end
        else
            session[:nonce] = nonce
        end

        master_key = params[:MASTER_KEY].to_s
        if master_key.to_s == ""
            master_key = session[:master_key].to_s
            if master_key.to_s == ""
                master_key = cookies.signed[:master_key].to_s
                if master_key == ""
                    nonce = ""
                end
            end
        else
            session[:master_key] = master_key
        end

        password = ""
        if nonce != ""
            begin
                # get cipher
                nonce_url = pia_url + '/api/support/' + nonce
                response = HTTParty.get(nonce_url)
                if response.code == 200
                    cipher = response.parsed_response["cipher"]
                    cipherHex = [cipher].pack('H*')
                    nonceHex = [nonce].pack('H*')
                    keyHash = [master_key].pack('H*')
                    private_key = RbNaCl::PrivateKey.new(keyHash)
                    authHash = RbNaCl::Hash.sha256('auth'.force_encoding('ASCII-8BIT'))
                    auth_key = RbNaCl::PrivateKey.new(authHash).public_key
                    box = RbNaCl::Box.new(auth_key, private_key)
                    password = box.decrypt(nonceHex, cipherHex)

                    # write to cookies in any case if NONCE is provided in URL
                    cookies.permanent.signed[:pia_url] = pia_url
                    cookies.permanent.signed[:app_key] = app_key
                    cookies.permanent.signed[:app_secret] = app_secret
                    cookies.permanent.signed[:password] = password

                end
            rescue
                
            end
        end
        if params[:password].to_s != ""
            password = params[:password].to_s
        end
        cookie_password = false
        if password.to_s == ""
            password = session[:password].to_s
            if password.to_s == ""
                password = cookies.signed[:password]
                if password.to_s != ""
                    cookie_password = true
                end
            end
        else
            session[:password] = password
            if params[:remember].to_s == "1"
                cookies.permanent.signed[:pia_url] = pia_url
                cookies.permanent.signed[:app_key] = app_key
                cookies.permanent.signed[:app_secret] = app_secret
                cookies.permanent.signed[:password] = password
            end
        end
        @pia_url = pia_url
        @app_key = app_key
        @app_secret = app_secret

        # puts "pia_url: " + pia_url.to_s
        # puts "app_key: " + app_key.to_s
        # puts "app_secret: " + app_secret.to_s
        # puts "password: " + password.to_s

        token = getToken(pia_url, app_key, app_secret).to_s
        if token == ""
            redirect_to error_path(pia_url: pia_url)
            return
        end
        session[:token] = token
        # puts "token: " + token.to_s

        if password.to_s == ""
            redirect_to password_path(pia_url: pia_url)
            return
        end

        app = setupApp(pia_url, app_key, app_secret)
        app["password"] = password.to_s
        if getReadKey(app).nil?
            if cookie_password
                flash[:warning] = t('general.wrongCookiePassword')
            else
                flash[:warning] = t('general.wrongPassword')
            end
            redirect_to password_path(pia_url: pia_url, app_key: app_key, app_secret: app_secret)
            return
        end
        if request.post?
            redirect_to root_path
        end

        dec_url = itemsUrl(app["pia_url"], "oyd.consent")
        @items = readRawItems(app, dec_url)

    end

    def detail
        pia_url = session[:pia_url]
        app_key = session[:app_key]
        app_secret = session[:app_secret]
        password = session[:password].to_s

        app = setupApp(pia_url, app_key, app_secret)
        app["password"] = password.to_s
        if getReadKey(app).nil?
            if cookie_password
                flash[:warning] = t('general.wrongCookiePassword')
            else
                flash[:warning] = t('general.wrongPassword')
            end
            redirect_to password_path(pia_url: pia_url, app_key: app_key, app_secret: app_secret)
            return
        end

        @detail = {}
        dec_url = itemsUrl(app["pia_url"], "oyd.consent")
        @items = readRawItems(app, dec_url)
        @items.each do |i|
            item = JSON.parse(i.to_s)
            if item["id"].to_s == params[:id].to_s
                @detail = item
                break
            end
        end

    end

    def trace
# puts "Service Endpoint: " + params[:srv].to_s
# puts "ID: " + params[:id].to_s
        response = HTTParty.get(params[:srv].to_s + "/api/rcpt/" + params[:id].to_s)
        render plain: JSON.pretty_generate(response.parsed_response)
    end

    def revoke
        response = HTTParty.delete(params[:srv].to_s + "/api/receipt/" + params[:id].to_s + "/revoke",
                        headers: { 'Content-Type'   => 'application/json' },
                        body:    { 'revocation_key': params[:key].to_s }.to_json)
        if response.code == 200
            flash[:success] = t('message.success')
        else
            flash[:warning] = t('message.failure')
        end
puts response.parsed_response.to_json        
        redirect_to detail_path(id: params[:detail])
    end

    def error
        @pia_url = params[:pia_url]
    end

    def password
        @pia_url = params[:pia_url]
        @app_key = params[:app_key]
        @app_secret = params[:app_secret]
    end

    def favicon
        send_file 'public/favicon.ico', type: 'image/x-icon', disposition: 'inline'
    end
    
end
