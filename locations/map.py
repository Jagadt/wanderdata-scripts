import matplotlib.pyplot as plt
import geopandas as gpd
import pandas as pd


def load_data():
    df = pd.read_csv('data/places.csv')
    # Countries data taken and modified from https://github.com/datasets/geo-countries
    c = gpd.read_file('data/countries.geojson')
    grouped = df.groupby(['Country']).size().reset_index(name='n')

    merged_df = c.merge(grouped, how='inner',
                        left_on='ADMIN', right_on='Country')
    merged_df['n'] = merged_df['n'].fillna(0)

    return merged_df


def plot_map(df):
    df.plot(
        figsize=(8, 8), edgecolor=u'gray', cmap='tab20', column='ADMIN',
        legend=True)

    plt.ylabel('Latitude')
    plt.xlabel('Longitude')
    plt.title('Countries visited')

    plt.show()


if __name__ == "__main__":
    df = load_data()
    plot_map(df)
