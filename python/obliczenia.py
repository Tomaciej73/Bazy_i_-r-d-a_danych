import cx_Oracle
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats
from sklearn.linear_model import LinearRegression
from show import getGoals
from connect import cur

goals = list(getGoals())
df = pd.DataFrame(goals, columns=['home_score', 'away_score'])

print("Gole: ", goals)

print("Suma: ", round(np.sum(goals), 2))
print("Średnia: ", round(np.mean(goals), 2))
print("Odchylenie standardowe: ", round(np.std(goals), 2))

#analiza wariancji
k = df['home_score'].var(ddof=0)
print('k = %.1f' % k)

#niezależne
test_2 = stats.ttest_ind(df['home_score'], df['away_score'])

#zależne
test_4 = stats.ttest_rel(df['home_score'], df['away_score'])

if test_2[1] < 1e-5:
    print("Test 1 niezależny bardzo bliski zeru")
else:
    print("Test 1 niezależny: ", round(test_2[1], 5))

if test_4[1] < 1e-5:
    print("Test 2 zależny bardzo bliski zeru")
else:
    print("Test 2 zależny: ", round(test_4[1], 5))

#regresja liniowa
x = np.array(df['home_score']).reshape((-1, 1))
y = np.array(df['away_score'])

model = LinearRegression()
model.fit(x, y)
model = LinearRegression().fit(x, y)

r_sq = model.score(x, y)
print('Współczynnik determinacji: ', round(r_sq, 2))

result_cursor = cur.var(cx_Oracle.CURSOR)
cur.callproc('BYYEARS', [result_cursor])
result_data = result_cursor.getvalue().fetchall()

df = pd.DataFrame(result_data, columns=['year', 'home_score', 'away_score'])
df['home_score'] = df['home_score'].round(2)
df['away_score'] = df['away_score'].round(2)

plt.bar(df['year'], df['home_score'])
plt.xlabel('Rok')
plt.ylabel('Suma wyników gospodarzy')
plt.title('Wyniki drużyny gospodarzy w danym roku')
plt.show()

plt.bar(df['year'], df['away_score'], color='orange')
plt.xlabel('Rok')
plt.ylabel('Suma wyników gości')
plt.title('Wyniki drużyny gości w danym roku')
plt.show()
