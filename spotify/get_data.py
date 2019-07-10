import logging
import sys
import pandas_gbq
import pandas as pd
import sys

logger = logging.getLogger('pandas_gbq')
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler(stream=sys.stdout))
print(sys.argv[3])

# read data from BigQuery
query = """
SELECT
  *
FROM
  `{}`
WHERE
  PlayedAt >= '{}' AND
  PlayedAt < '{}'
""".format(sys.argv[1], sys.argv[3], sys.argv[4])
df = pandas_gbq.read_gbq(query, project_id=sys.argv[2],
                         dialect='standard')

df.to_csv('df.csv', index=False, encoding='utf-8')
