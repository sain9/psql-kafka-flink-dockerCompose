
grant_type: password
username: hussain
password: hussain
client secret: c2zsEIG7NfBZANKb9AWifir8uqfinyoS
client_id: platform-gateway

#one line curl
curl --location 'http://localhost:9001/realms/platform/protocol/openid-connect/token' --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode 'grant_type=password' --data-urlencode 'client_id=platform-gateway' --data-urlencode 'client_secret=c2zsEIG7NfBZANKb9AWifir8uqfinyoS' --data-urlencode 'username=hussain' --data-urlencode 'password=hussain'

#curl command to generate token
curl --location 'http://localhost:9001/realms/platform/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'client_id=platform-gateway' \
--data-urlencode 'client_secret=c2zsEIG7NfBZANKb9AWifir8uqfinyoS' \
--data-urlencode 'username=hussain' \
--data-urlencode 'password=hussain'
