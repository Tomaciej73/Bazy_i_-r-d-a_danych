import pandas as pd
import string
from show import *
from connect import connection, cur
from check import checkScore, checkDate

df = pd.read_csv('dane.csv', delimiter=',', encoding="utf_8")

cities = df['city'].unique()
countries = df['country'].unique()
concat_teams = pd.Series(list(df['home_team']) + list(df['away_team'])).unique()
tournaments = df['tournament'].unique()


def exec():
    #updateCity()
    #updateCountry()
    #updateTeams()
    #updateTournaments()
    #updateGames()
    print("I myk gotowe!")


# Wstaw dane z csv do CITY
def updateCity():
    cur.execute('DELETE FROM KARKULOWSKIT.CITY') # Usun wszystko z tabeli CITY
    cur.execute('TRUNCATE TABLE KARKULOWSKIT.CITY') # Usun wszystkie wiersze bez odzyskiwania ROLLBACK
    for city in cities: # wstaw dane z csv z kolumny tournament
        tmp = ""
        acc = """ '",{}[].`;: -' ’‘"""
        for x in city:
            if x in string.ascii_letters or x in string.digits or x in acc:
                tmp += x
        cur.execute('INSERT INTO KARKULOWSKIT.CITY(CITY_NAME) VALUES (:1)', [tmp])
        connection.commit()

# Wstaw dane z csv do COUNTRY
def updateCountry():
    cur.execute('DELETE FROM KARKULOWSKIT.COUNTRY')
    cur.execute('TRUNCATE TABLE KARKULOWSKIT.COUNTRY')
    for country in countries:
        cur.execute('INSERT INTO KARKULOWSKIT.COUNTRY(COUNTRY_NAME) VALUES (:1)', [country])
        connection.commit()

# Wstaw dane z csv do TEAM
def updateTeams():
    cur.execute('DELETE FROM KARKULOWSKIT.TEAM')
    cur.execute('TRUNCATE TABLE KARKULOWSKIT.TEAM')
    for team in concat_teams:
        tmp = ""
        acc = """ '",{}[].`;: - """
        for x in team:
            if x in string.ascii_letters or x in string.digits or x in acc:
                tmp += x
        cur.execute('INSERT INTO KARKULOWSKIT.TEAM(TEAM_NAME) VALUES (:1)', [tmp])
        connection.commit()

# Wstaw dane z csv do TOURNAMENTS
def updateTournaments():
    cur.execute('DELETE FROM KARKULOWSKIT.TOURNAMENT')
    cur.execute('TRUNCATE TABLE KARKULOWSKIT.TOURNAMENT')
    for tournament in tournaments:
        cur.execute('INSERT INTO KARKULOWSKIT.TOURNAMENT(TOURNAMENT_NAME) VALUES (:1)', [tournament])
        connection.commit()

# Wstaw dane z csv do GAME
def updateGames():
    #cur.execute('SET FOREIGN_KEY_CHECKS = 0')
    cur.execute('DELETE FROM KARKULOWSKIT.GAME')
    cur.execute('TRUNCATE TABLE KARKULOWSKIT.GAME')
    #cur.execute('SET FOREIGN_KEY_CHECKS = 1')
    imp_cities = list(importCity())
    imp_countries = list(importCountries())
    imp_teams = list(importTeams())
    imp_tournaments = list(importTournament())

    sql = 'INSERT INTO KARKULOWSKIT.GAME(GAME_DATE, HOME_TEAM_ID, AWAY_TEAM_ID, ' \
          'HOME_SCORE, AWAY_SCORE, TOURNAMENT_ID, CITY_ID, COUNTRY_ID, NEUTRAL) ' \
          'VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9)'
    for index, row in df.iterrows():
        try:
            val = (row['date'],
                   [item for item in imp_teams if item[1] == row['home_team']][0][0],
                   [item for item in imp_teams if item[1] == row['away_team']][0][0],
                   checkScore(row['home_score']),
                   checkScore(row['away_score']),
                   [item for item in imp_tournaments if item[1] == row['tournament']][0][0],
                   list(filter(lambda x: x[1] == row['city'], imp_cities))[0][0],
                   [item for item in imp_countries if item[1] == row['country']][0][0],
                   row['neutral']
                   )
            #print(f"Wstawianie wartości: {val}")
            cur.execute(sql, val)
            connection.commit()
        except IndexError as e:
            print(f"Błąd w wierszu {index}: {e}")

exec()


