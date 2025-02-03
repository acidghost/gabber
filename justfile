bundle_prefix := '~'
prefix := '~/.local'
bin := prefix + '/bin'

version := '1.0.0'

out:
    mkdir -p out

bundle: out
    platypus \
        --name Gabber \
        --app-version {{version}} \
        --bundle-identifier rip.555.Gabber \
        --author acidghost \
        --interpreter /usr/bin/env \
        --interpreter-args python3 \
        --script-args '--platypus' \
        --uri-schemes gabber \
        --interface-type 'None' \
        --background \
        --quit-after-execution \
        --overwrite \
        git-gabber.py \
        out/Gabber.app

dmg: bundle
    hdiutil create \
        -volname "Gabber" \
        -srcfolder out/Gabber.app \
        -ov -format UDZO \
        out/Gabber.dmg

install: bundle
    cp -r out/Gabber.app {{bundle_prefix}}/Applications
    install -m 755 git-gabber.py {{bin}}/git-gabber

extension: out
    npm run ext:build

sign-extension: out
    FIREFOX_API_KEY=$(cat .api-key) \
    FIREFOX_API_SECRET=$(cat .api-secret) \
        npm run ext:sign

clean:
    rm -rf out
