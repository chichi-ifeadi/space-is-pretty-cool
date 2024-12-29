#!/bin/bash
# Script to insert data about the universe; galaxies, stars, planets, moons, and extras

# Connect to the database
PSQL="psql -X --username=freecodecamp --dbname=universe --no-align --tuples-only -c"

# Truncate tables to remove any previous data
echo $($PSQL "TRUNCATE galaxy, star, planet, moon, extra RESTART IDENTITY CASCADE")

# Read galaxy.csv
cat galaxy.csv | while IFS="," read NAME HAVE_TYPE DISTANCE DIAMETER DESCRIPTION
do
    # Skip the header row
    if [[ $NAME != "galaxy" ]]
    then
        # Insert galaxy
        INSERT_GALAXY_RESULT=$($PSQL "INSERT INTO galaxy(name, have_type, distance, diameter, description) 
                                      VALUES('$NAME', '$HAVE_TYPE', $DISTANCE, $DIAMETER, '$DESCRIPTION')")
        if [[ $INSERT_GALAXY_RESULT == "INSERT 0 1" ]]
        then
            echo "Inserted into galaxy, $NAME"
        fi
    fi
done

# Read star.csv
cat star.csv | while IFS="," read GALAXY_ID MASS ABS_MAGNITUDE HAS_PLANETS STAR_NAME
do
    # Skip the header row
    if [[ $STAR_NAME != "star" ]]
    then
        # Get galaxy_id by galaxy_name (this should already be the correct galaxy_id from the CSV)
        GALAXY_ID=$($PSQL "SELECT galaxy_id FROM galaxy WHERE galaxy_id = $GALAXY_ID")

        # If galaxy_id is not found, skip insertion
        if [[ -z $GALAXY_ID ]]
        then
            echo "No matching galaxy found for star $STAR_NAME, skipping insertion."
            continue
        fi

        # Handle YES/NO for HAS_PLANETS field
        if [[ "$HAS_PLANETS" == "Yes" || "$HAS_PLANETS" == "yes" ]]
        then
            HAS_PLANETS=true
        else
            HAS_PLANETS=false
        fi

        # Insert star
        INSERT_STAR_RESULT=$($PSQL "INSERT INTO star(galaxy_id, mass, abs_magnitude, has_planets, name)
                                    VALUES($GALAXY_ID, $MASS, $ABS_MAGNITUDE, $HAS_PLANETS, '$STAR_NAME')")
        if [[ $INSERT_STAR_RESULT == "INSERT 0 1" ]]
        then
            echo "Inserted into star, $STAR_NAME"
        fi
    fi
done

# Insert data from planets.csv
cat planet.csv | while IFS="," read NAME HAS_RINGS PLANET_TYPE DENSITY YEAR_DISCOVERED STAR_ID
do
  # Skip header row
  if [[ $NAME != "planet" ]]
  then
    # Get star_id  by star name
    STAR_ID=$($PSQL "SELECT star_id FROM star WHERE star_id = $STAR_ID")
    
    # If star_id is not found, skip insertion
    if [[ -z $STAR_ID ]]
    then
      echo "No matching galaxy found for $NAME, skipping insertion."
      continue
    fi
    
    # Insert planet
    INSERT_PLANET_RESULT=$($PSQL "INSERT INTO planet(name, has_rings, planet_type, density, year_discovered, star_id) 
                                  VALUES('$NAME', '$HAS_RINGS', '$PLANET_TYPE', $DENSITY, $YEAR_DISCOVERED, $STAR_ID)")
    if [[ $INSERT_PLANET_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into planet, $NAME"
    fi
  fi
done

# Insert data from moon.csv
cat moon.csv | while IFS="," read NAME ABS_MAGNITUDE DIAMETER YEAR_DISCOVERED PLANET_ID
do
  # Skip header row
  if [[ $NAME != "moon" ]]
  then
    # Get planet_id by planet id
    PLANET_ID=$($PSQL "SELECT planet_id FROM planet WHERE planet_id = '$PLANET_ID'")
    
    # If planet_id is not found, skip insertion
    if [[ -z $PLANET_ID ]]
    then
      echo "No matching planet found for moon $NAME, skipping insertion."
      continue
    fi
    
    # Insert moon
    INSERT_MOON_RESULT=$($PSQL "INSERT INTO moon(name, absolute_magnitude, diameter, year_disc, planet_id)
                                VALUES('$NAME', $ABS_MAGNITUDE, $DIAMETER, $YEAR_DISCOVERED, $PLANET_ID)")
    if [[ $INSERT_MOON_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into moon, $NAME"
    fi
  fi
done

#Insert data from extra.csv
cat extra.csv | while IFS="," read OBJECT_ID NAME DESCRIPTION
do
  # Skip header row
  if [[ $NAME != "object_id" ]]
  then
    # Insert extra celestial bodies
    INSERT_EXTRA_RESULT=$($PSQL "INSERT INTO extra(object_id, name, description)
                                VALUES( '$OBJECT_ID', '$NAME', '$DESCRIPTION')")
    if [[ $INSERT_EXTRA_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into extra, $NAME"
    fi
  fi
done
