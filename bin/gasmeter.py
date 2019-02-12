import RPi.GPIO as GPIO
import time
import sqlite3 as lite

GPIO.setmode(GPIO.BOARD)
GPIO.setwarnings(False)

# GPIO define
REED_gas = 21
# define GPIO as INPUT and set it also as PULUPDOWN
GPIO.setup(REED_gas, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# database
database = "/opt/loxberry/data/plugins/gasmeter/gasmeter_database.sqlite3"
db = lite.connect(database)

state_old=1
while True:
    state_actual = GPIO.input(REED_gas)
    # REEDKONTAKT geoeffnet
    if state_actual == 1:
        print "contact open"
        state_old=GPIO.input(REED_gas)
        # REEDKONTAKT geschlossen
    elif state_actual==0:
        print "contact closed"
        if state_old!=state_actual:
            state_old=GPIO.input(REED_gas)
            # Impuls into Database insert
            cursor = db.cursor()
            cursor.execute("""INSERT INTO gasmeter_t (timestamp,counter) VALUES (CURRENT_TIMESTAMP,1)""")
            db.commit()
            cursor.close()
    time.sleep(1)

