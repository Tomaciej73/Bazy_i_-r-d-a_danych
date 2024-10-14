import numpy as np
import datetime

def checkScore(value):
    if value < 0:
        return np.NaN
    else:
        return value


def checkDate(value):
    if datetime.date(*map(int, value.split('-'))) < datetime.datetime.now():
        date = datetime.date(*map(int, value.split('-')))
    print(date)
