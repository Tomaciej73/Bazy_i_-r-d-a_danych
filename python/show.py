import pandas as pd
from connect import cur

def showCity():
    try:
        cur.execute('SELECT * FROM KARKULOWSKIT.CITY')
        result = cur.fetchall()
        df = pd.DataFrame(result, columns=['ID', 'City Name'])
        print(df.head(10).to_string(index=False))  # Wyświetla 10 pierwszych wierszy
        return result
    except Exception as e:
        print(f"Błąd pobierania danych z tabeli CITY: {e}")
        return []


def showCountries():
    try:
        cur.execute('SELECT * FROM KARKULOWSKIT.COUNTRY')
        result = cur.fetchall()
        df = pd.DataFrame(result, columns=['ID', 'Country Name'])
        print(df.head(10).to_string(index=False))  # Wyświetla 10 pierwszych wierszy
        return result
    except Exception as e:
        print(f"Błąd pobierania danych z tabeli COUNTRY: {e}")
        return []


def showTeams():
    try:
        cur.execute('SELECT * FROM KARKULOWSKIT.TEAM')
        result = cur.fetchall()
        df = pd.DataFrame(result, columns=['ID', 'Team Name'])
        print(df.head(10).to_string(index=False))
        return result
    except Exception as e:
        print(f"Błąd pobierania danych z tabeli TEAM: {e}")
        return []


def showTournament():
    try:
        cur.execute('SELECT * FROM KARKULOWSKIT.TOURNAMENT')
        result = cur.fetchall()
        df = pd.DataFrame(result, columns=['ID', 'Tournament Name'])
        print(df.head(10).to_string(index=False))
        return result  # Zwraca dane jako listę krotek
    except Exception as e:
        print(f"Błąd pobierania danych z tabeli TOURNAMENT: {e}")
        return []


def showGames():
    cur.execute('SELECT * FROM KARKULOWSKIT.GAME')
    result = cur.fetchall()
    df = pd.DataFrame(result, columns=['ID', 'Game Date', 'Home Team ID', 'Away Team ID', 'Home Score', 'Away Score', 'Tournament ID', 'City ID', 'Country ID', 'Neutral'])
    print(df.head(10).to_string(index=False))

def getGoals():
    cur.execute('SELECT home_score,away_score FROM KARKULOWSKIT.GAME')
    return cur.fetchall()

if __name__ == "__main__":
    #showTournament()
    #showGames()
    #showCity()
    #showCountries()
    showTeams()
