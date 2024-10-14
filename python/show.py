import pandas as pd
from show import *
from connect import cur

def showCity():
    cur.execute('SELECT * FROM KARKULOWSKIT.CITY')
    result = cur.fetchall()
    df = pd.DataFrame(result, columns=['ID','City Name'])
    print(df.head(10).to_string(index=False))

def showCountries():
    cur.execute('SELECT * FROM KARKULOWSKIT.COUNTRY')
    result = cur.fetchall()
    df = pd.DataFrame(result, columns=['ID','Country Name'])
    print(df.head(10).to_string(index=False))

def showTeams():
    cur.execute('SELECT * FROM KARKULOWSKIT.TEAM')
    result = cur.fetchall()
    df = pd.DataFrame(result, columns=['ID','Team Name'])
    print(df.head(10).to_string(index=False))

def showTournament():
    cur.execute('SELECT * FROM KARKULOWSKIT.TOURNAMENT')
    result = cur.fetchall()
    df = pd.DataFrame(result, columns=['ID', 'Tournament Name'])
    print(df.head(10).to_string(index=False))

def showGames():
    cur.execute('SELECT * FROM KARKULOWSKIT.GAME')
    result = cur.fetchall()
    df = pd.DataFrame(result, columns=['ID', 'Game Date', 'Home Team ID', 'Away Team ID', 'Home Score', 'Away Score', 'Tournament ID', 'City ID', 'Country ID', 'Neutral'])
    print(df.head(10).to_string(index=False))

if __name__ == "__main__":
    #showTournament()
    #showGames()
    #showCity()
    #showCountries()
    showTeams()
