import foursquare
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--client_id', '-ci', help='Client id', type=str)
parser.add_argument('--client_secret', '-cs', help='Client secret', type=str)

args = parser.parse_args()
client_id = args.client_id
client_secret = args.client_secret

# Construct the client object
client = foursquare.Foursquare(client_id=client_id, client_secret=client_secret,
                               redirect_uri='https://juandes.com/oauth/authorize')

# Build the authorization url for your app
auth_uri = client.oauth.auth_url()

print(auth_uri)