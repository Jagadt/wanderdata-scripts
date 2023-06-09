import foursquare
import argparse
import datetime
import json
from pytz import timezone

parser = argparse.ArgumentParser()
parser.add_argument('--start_date', '-bd', help='Starting date', type=str,
                    default='2019-07-04')
parser.add_argument('--end_date', '-ed', help='End date', type=str,
                    default='2019-12-31')
parser.add_argument('--client_id', '-ci', help='Client id', type=str)
parser.add_argument('--client_secret', '-cs', help='Client secret', type=str)
parser.add_argument('--access_code', type=str)
args = parser.parse_args()
start_date = args.start_date
end_date = args.end_date
client_id = args.client_id
client_secret = args.client_secret
access_code = args.access_code

client = foursquare.Foursquare(client_id=client_id, client_secret=client_secret,
                               redirect_uri='https://juandes.com/oauth/authorize')

# Get the user's access_token
access_token = client.oauth.get_token(access_code)

# Apply the returned access token to the client
client.set_access_token(access_token)

# Get the user's data
user = client.users()

# Change the given times to the corresponding time zone
start_ts = int(datetime.datetime.strptime(
    start_date, '%Y-%m-%d').replace(tzinfo=timezone('Asia/Singapore')).timestamp())
end_ts = int(datetime.datetime.strptime(
    end_date, '%Y-%m-%d').replace(tzinfo=timezone('Asia/Singapore')).timestamp())

offset = 0
data = []

while True:
    # Get the check-ins using afterTimestamp and beforeTimestamp to filter the result
    c = client.users.checkins(params={'afterTimestamp': start_ts,
                                      'beforeTimestamp': end_ts,
                                      'sort': 'newestfirst',
                                      'limit': 250,
                                      'offset': offset})
    # Break if there are no items
    if len(c['checkins']['items']) == 0:
        break

    for item in c['checkins']['items']:
        data.append(item)
    offset += 250

with open('data/checkins.json', 'a+') as fp:
    json.dump(data, fp)
