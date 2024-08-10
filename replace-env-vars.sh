# replace-env-vars.sh

cp fly.toml.template fly.toml
sed -i "s/PLACEHOLDER_APP_NAME/$APP_NAME/g" fly.toml