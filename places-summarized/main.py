import argparse
import time

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from places_summarized import Client

parser = argparse.ArgumentParser()
parser.add_argument('--key', '-K',
                    help="Google Maps API key", type=str, default='')
parser.add_argument('--location', '-L',
                    help="Location Coordinates; latitude,longitude", type=str,
                    default='-33.8670522, 151.1957362')
parser.add_argument('--radius', '-R', type=int,
                    default=1000)
parser.add_argument('--get', '-G', type=int,
                    default=0)


# Set Seaborn's color palette.
sns.set_color_codes()

# Parse the arguments
args = parser.parse_args()
key = args.key
location = args.location
radius = args.radius
number_gets = args.get

client = Client(key=key)
summary = client.places_summary(location=location, radius=radius)

# Get more results!
for i in range(number_gets):
    print(summary.nearby_results)
    time.sleep(5)
    client.get_more_results(summary)
    r = summary.result()


# Plot histogram of ratings
sns.distplot(r['ratings']).set_title(
    'Ratings of locations from {}'.format(location))
plt.savefig('{}_{}.png'.format(location, 'ratings'),
            dpi=320, orientation='landscape')
plt.clf()


# Plot the price levels
prices = r['price_levels']
# if there is more than one price, and they are not all the same
if len(prices) > 1 and len(set(prices)) > 1:
    sns.distplot(prices).set_title(
        'Prices levels of locations from {}'.format(location))
    plt.savefig('{}_{}.png'.format(location, 'price_levels'),
                dpi=320, orientation='landscape')
    plt.clf()


# Plot user_ratings_total
sns.distplot(r['user_ratings_total']).set_title(
    'Total user ratings of locations from {}'.format(location))
plt.savefig('{}_{}.png'.format(location, 'user_ratings_total'),
            dpi=320, orientation='landscape')
plt.clf()

# Plot location_types
df = pd.DataFrame.from_dict(r['location_types'], orient='index')
df.index.name = 'location'
df.reset_index(inplace=True)
df.rename(columns={0: 'val'}, inplace=True)
# Remove the row with point_of_interest and establishment location
df = df[(df.location != 'point_of_interest') & (df.location != 'establishment')]

plt.figure(figsize=(16, 11))
sns.barplot(x="location", y="val", data=df, order=df.sort_values(
    'val', ascending=False)['location']).set_title('Location types from {}'.format(location))
plt.xticks(rotation=45)
plt.subplots_adjust(bottom=0.15)
plt.savefig('{}_{}.png'.format(location, 'types'),
            dpi=320, orientation='landscape')
plt.clf()

# Plot the location percentage
df['location_percentage'] = (df.val / summary.num_locations) * 100
sns.barplot(x="location", y="location_percentage", data=df, order=df.sort_values(
    'val', ascending=False)['location']).set_title('Location percentage types from {}'.format(location))
plt.xticks(rotation=45)
plt.savefig('{}_{}.png'.format(location, 'location_percentage'),
            dpi=320, orientation='landscape')
plt.clf()

# Print the complete summary
print(r)
