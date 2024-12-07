import cx_Oracle
import pandas as pd
import string
from show import *
from connect import connection, cur
from check import checkScore, checkDate
import time
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
    updateGames()

# Wstaw dane z csv do CITY
def updateCity():
    total_rows = len(cities)
    try:
        cur.execute('DELETE FROM KARKULOWSKIT.CITY')  # Usuń wszystko z tabeli CITY
        #cur.execute('TRUNCATE TABLE KARKULOWSKIT.CITY')  # Bez ROLLBACK
    except cx_Oracle.IntegrityError as e:
        if "ORA-02292" in str(e):
            print("Znaleziono rekordy podrzędne. Usuwanie danych z GAME...")
            updateGames(delete_only=True)  # Najpierw usuń dane z GAME
            cur.execute('DELETE FROM KARKULOWSKIT.CITY')
            #cur.execute('TRUNCATE TABLE KARKULOWSKIT.CITY')
    for index, city in enumerate(cities):
        tmp = ""
        acc = """ '",{}[].`;: -' ’‘"""
        for x in city:
            if x in string.ascii_letters or x in string.digits or x in acc:
                tmp += x
        cur.execute('INSERT INTO KARKULOWSKIT.CITY(CITY_NAME) VALUES (:1)', [tmp])
        connection.commit()
        progress = ((index + 1) / total_rows) * 100
        print(f"\rPostęp CITY: {progress:.2f}% ({index + 1}/{total_rows} wierszy)", end="")
    print("\nDane do tabeli CITY zostały wgrane pomyślnie.")

# Wstaw dane z csv do COUNTRY
def updateCountry():
    total_rows = len(countries)
    try:
        cur.execute('DELETE FROM KARKULOWSKIT.COUNTRY')  # Usuń wszystko z tabeli COUNTRY
        #cur.execute('TRUNCATE TABLE KARKULOWSKIT.COUNTRY')  # Bez ROLLBACK
    except cx_Oracle.IntegrityError as e:
        if "ORA-02292" in str(e):
            print("Znaleziono rekordy podrzędne. Usuwanie danych z GAME...")
            updateGames(delete_only=True)  # Najpierw usuń dane z GAME
            cur.execute('DELETE FROM KARKULOWSKIT.COUNTRY')
            #cur.execute('TRUNCATE TABLE KARKULOWSKIT.COUNTRY')
    for index, country in enumerate(countries):
        cur.execute('INSERT INTO KARKULOWSKIT.COUNTRY(COUNTRY_NAME) VALUES (:1)', [country])
        connection.commit()
        progress = ((index + 1) / total_rows) * 100
        print(f"\rPostęp COUNTRY: {progress:.2f}% ({index + 1}/{total_rows} wierszy)", end="")
    print("\nDane do tabeli COUNTRY zostały wgrane pomyślnie.")

# Wstaw dane z csv do TEAM
def updateTeams():
    total_rows = len(concat_teams)
    try:
        cur.execute('DELETE FROM KARKULOWSKIT.TEAM')  # Usuń wszystko z tabeli TEAM
        #cur.execute('TRUNCATE TABLE KARKULOWSKIT.TEAM')  # Bez ROLLBACK
    except cx_Oracle.IntegrityError as e:
        if "ORA-02292" in str(e):
            print("Znaleziono rekordy podrzędne. Usuwanie danych z GAME...")
            updateGames(delete_only=True)  # Najpierw usuń dane z GAME
            cur.execute('DELETE FROM KARKULOWSKIT.TEAM')
            #cur.execute('TRUNCATE TABLE KARKULOWSKIT.TEAM')
    for index, team in enumerate(concat_teams):
        tmp = ""
        acc = """ '",{}[].`;: - """
        for x in team:
            if x in string.ascii_letters or x in string.digits or x in acc:
                tmp += x
        cur.execute('INSERT INTO KARKULOWSKIT.TEAM(TEAM_NAME) VALUES (:1)', [tmp])
        connection.commit()
        progress = ((index + 1) / total_rows) * 100
        print(f"\rPostęp TEAM: {progress:.2f}% ({index + 1}/{total_rows} wierszy)", end="")
    print("\nDane do tabeli TEAM zostały wgrane pomyślnie.")

# Wstaw dane z csv do TOURNAMENTS
def updateTournaments():
    total_rows = len(tournaments)
    try:
        cur.execute('DELETE FROM KARKULOWSKIT.TOURNAMENT')  # Usuń wszystko z tabeli TEAM
        #cur.execute('TRUNCATE TABLE KARKULOWSKIT.TOURNAMENT')  # Bez ROLLBACK
    except cx_Oracle.IntegrityError as e:
        if "ORA-02292" in str(e):
            print("Znaleziono rekordy podrzędne. Usuwanie danych z GAME...")
            updateGames(delete_only=True)  # Najpierw usuń dane z GAME
            cur.execute('DELETE FROM KARKULOWSKIT.TOURNAMENT')
            #cur.execute('TRUNCATE TABLE KARKULOWSKIT.TOURNAMENT')
    for index, tournament in enumerate(tournaments):
        cur.execute('INSERT INTO KARKULOWSKIT.TOURNAMENT(TOURNAMENT_NAME) VALUES (:1)', [tournament])
        connection.commit()
        progress = ((index + 1) / total_rows) * 100
        print(f"\rPostęp TOURNAMENT: {progress:.2f}% ({index + 1}/{total_rows} wierszy)", end="")
    print("\nDane do tabeli TOURNAMENT zostały wgrane pomyślnie.")

def safe_lookup(value, lookup_list, column_index=0):
    """
    Bezpieczne wyszukiwanie wartości w liście.
    Zwraca wynik lub None, jeśli nie znaleziono.
    """
    result = [item[column_index] for item in lookup_list if item[1] == value]
    return result[0] if result else None


# Wstaw dane z csv do GAME
def updateGames(delete_only=False):
    total_rows = len(df)
    try:
        cur.execute('DELETE FROM KARKULOWSKIT.GAME')
        if delete_only:
            print("Dane z tabeli GAME zostały usunięte.")
            return
    except Exception as e:
        print(f"Błąd podczas usuwania danych z GAME: {e}")
        return

    imp_cities = showCity()
    imp_countries = showCountries()
    imp_teams = showTeams()
    imp_tournaments = showTournament()

    sql = 'INSERT INTO KARKULOWSKIT.GAME(GAME_DATE, HOME_TEAM_ID, AWAY_TEAM_ID, ' \
          'HOME_SCORE, AWAY_SCORE, TOURNAMENT_ID, CITY_ID, COUNTRY_ID, NEUTRAL) ' \
          'VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9)'

    for index, row in df.iterrows():
        try:
            val = (
                row['date'],
                safe_lookup(row['home_team'], imp_teams),
                safe_lookup(row['away_team'], imp_teams),
                checkScore(row['home_score']),
                checkScore(row['away_score']),
                safe_lookup(row['tournament'], imp_tournaments),
                safe_lookup(row['city'], imp_cities),
                safe_lookup(row['country'], imp_countries),
                row['neutral']
            )
            if None in val:
                #print(f"Błąd mapowania wiersza {index}: {row}")
                continue

            cur.execute(sql, val)
            connection.commit()
            progress = ((index + 1) / total_rows) * 100
            print(f"\rPostęp GAME: {progress:.2f}% ({index + 1}/{total_rows} wierszy)", end="")
        except Exception as e:
            print(f"\nBłąd w wierszu {index}: {e}")
    print("\nDane do tabeli GAME zostały wgrane pomyślnie.")


exec()
