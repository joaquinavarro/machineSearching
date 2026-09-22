#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n$redColour[!] Saliendo ...\n $endColour"
  tput cnorm && exit 1
}

# Control + c
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"
bundle_file="bundle.js"
temp_bundle_file="bundle_temp.js"

function help(){
  echo -e "\n ${greenColour}[+]${endColour} Uso:"
  echo -e "\t ${purpleColour}u)${endColour} Descargar o actualizar archivos" 
  echo -e "\t ${purpleColour}m)${endColour} Buscar por nombre de máquina"
  echo -e "\t ${purpleColour}i)${endColour} Buscar máquina por dirección IP"
  echo -e "\t ${purpleColour}d)${endColour} Buscar máquinas por dificultad"
  echo -e "\t ${purpleColour}o)${endColour} Buscar máquinas por sistema operativo"
  echo -e "\t ${purpleColour}s)${endColour} Buscar máquinas por skills"
  echo -e "\t ${purpleColour}y)${endColour} Video de la resolución de la máquina"
  echo -e "\t ${purpleColour}h)${endColour} Panel de ayuda"
}

function searchMachineByName(){
  machineName="$1"
  machine_exists=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '""' | tr -d "," | sed 's/^ *//')

  if [ "$machine_exists" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Listando las propiedades de la máquina: ${endColour}${purpleColour}${machineName}${endColour}\n"
    cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '""' | tr -d "," | sed 's/^ *//'

  else
    echo -e "\n ${redColour} [-] ${endColour}${grayColour}La máquina proporcionada no existe. ${endColour}"
  fi
}

function updateContent(){
  if [ ! -f ${bundle_file} ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Descargar archivos necesarios...${endColour}"
    curl -s $main_url > ${bundle_file}
    js-beautify $bundle_file | sponge ${bundle_file}
    sleep 1
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Archivos descargardos con exito.${endColour}"
    tput cnorm
  else
    tput civis 
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Buscando actualizaciones pendientes....${endColour}"
    curl -s $main_url > $temp_bundle_file
    js-beautify $temp_bundle_file | sponge $temp_bundle_file

    md5_value=$(md5sum ${bundle_file} | awk '{print $1}')
    md5_temp_value=$(md5sum ${temp_bundle_file} | awk '{print $1}')
    
    if [ "$md5_temp_value" == "$md5_value" ]; then  
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour} No hay actualizaciones.${endColour}"
      rm $temp_bundle_file
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Hay actualizaciones.${endColour}"
      rm $bundle_file && mv $temp_bundle_file $bundle_file 
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Archivos actualizados con exito.${endColour}"
    fi
    tput cnorm   
  fi
}

function ipAdress(){
  ip="$1"
  machineName=$(cat bundle.js | grep "ip: \"${ip}\"" -B 3 | grep "name:" | tr -d "\"," | awk 'NF{print $NF}')
  
  if [ "$machineName" ]; then 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP: ${endColour}${blueColour}${ip}${endColour} Name:${turquoiseColour} ${machineName} ${endColour}"
    searchMachineByName $machineName
  else
    echo -e "\n ${redColour} [-] ${endColour}${grayColour}La IP proporcionada no existe. ${endColour}\n"
  fi
}

function showLink(){
  name="$1"
  machine_exists=$(cat bundle.js | awk "/name: \"${name}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '""' | tr -d "," | sed 's/^ *//' | grep "youtube:" | awk 'NF{print $NF}')

  if [ "$machine_exists" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Video resolución de la maquína${endColour} ${turquoiseColour}${name}${endColour}: ${machine_exists}"
  else 
    echo -e "\n ${redColour} [-] ${endColour}${grayColour}La máquina proporcionada no existe. ${endColour}"
  fi
}

function filterByDifficulty(){
  difficulty="$1"
  difficulty_exits=$(cat bundle.js | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name" | tr -d "\"," | awk 'NF{print $NF}' | column)
  
  if [ "$difficulty_exits" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas con dificultad ${endColour} ${turquoiseColour}${difficulty}${endColour}: ${machine_exists}\n"
    cat bundle.js| grep "dificultad: \"${difficulty}\"" -B 5 | grep "name:" | tr -d "\"," | awk 'NF{print $NF}' | column
  else
    echo -e "\n ${redColour} [-] ${endColour}${grayColour}La dificultad proporcionada no existe.${endColour}\n
    ${grayColour}Prueba${endColour} ${turquoiseColour}./htbmachines.sh -d ${endColour}${greenColour}(Fácil/Media/Difícil/Insane) ${endColour}" 
  fi
}

function filterByOs(){
  operation_system="$1"

  os_exists=$(cat bundle.js| grep "so: \"${operation_system}\"" -B 5 | grep "name:" | tr -d "\"," | awk 'NF {print $NF}' | column)

  if [ "$os_exists" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando máquinas cuyo sistema operativo es ${endColour}${turquoiseColour}${operation_system}${endColour}\n"
      cat bundle.js| grep "so: \"${operation_system}\"" -B 5 | grep "name:" | tr -d "\"," | awk 'NF {print $NF}' | column
  else 
    echo -e "\n ${redColour} [-] ${endColour}${grayColour}El sistema proporcionado no existe.${endColour}\n"
  fi  
}

function filterByDifficultyAndOS(){
  difficulty="$1"
  operation_system="$2"
  exists_os_or_diff=$(cat bundle.js| grep "so: \"${operation_system}\"" -C 4 | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name: " | tr -d "\"," | awk 'NF {print $NF}' | column)

 if [ "$exists_os_or_diff" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando máquinas cuya dificultad es ${endColour}${turquoiseColour}${difficulty}${endColour}${grayColour} y sistema operativo es ${endColour}${turquoiseColour}${operation_system}${endColour}: ${machine_exists}\n"
    cat bundle.js| grep "so: \"$operation_system\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | tr -d "\"," | awk 'NF {print $NF}' | column
  else
    echo -e "\n ${redColour} [-] ${endColour}${grayColour}El sistema o dificultad proporcionado no existe.${endColour}\n"
  fi
}

function filterBySkills(){
  skill="$1"

  skill_exists=$(cat bundle.js | grep "skills:" -B 6 | grep "${skill}" -i -B 6 | grep "name: " | tr -d "\"," | awk 'NF {print $NF}'| column)
  
  if [ "$skill_exists" ]; then
     echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando máquinas según la skill ${endColour}${turquoiseColour}${skill}${endColour}\n"
     cat bundle.js | grep "skills:" -B 6 | grep "${skill}" -i -B 6 | grep "name: " | tr -d "\"," | awk 'NF {print $NF}'| column
  else
    echo -e "\n ${redColour} [-] ${endColour}${grayColour}La skill proporcionado no existe.${endColour}\n"  
  fi
}

declare -i parameter_cond=0

# Chivatos
declare -i ch_difficulty=0
declare -i ch_os=0


while getopts "m:ui:y:d:o:s:h" arg; do 
  case $arg in
    m) name=$OPTARG; let parameter_cond+=1;; 
    u) let parameter_cond+=2;;   
    i) ip=$OPTARG; let parameter_cond+=3;;
    y) name=$OPTARG; let parameter_cond+=4;;
    d) difficulty=$OPTARG; ch_difficulty=+1; let parameter_cond+=5;;
    o) operation_system=$OPTARG; ch_os+=1; let parameter_cond+=6;;
    s) skill=$OPTARG; let parameter_cond+=7;;
    h) ;;
  esac
done

if [ $parameter_cond -eq 1 ]; then
  searchMachineByName $name
elif [ $parameter_cond -eq 2 ]; then
  updateContent
elif [ $parameter_cond -eq 3 ]; then
  ipAdress $ip
elif [ $parameter_cond -eq 4 ]; then
  showLink $name
elif [ $parameter_cond -eq 5 ]; then
  filterByDifficulty $difficulty
elif [ $parameter_cond -eq 6 ]; then
  filterByOs $operation_system
elif [ $ch_os -eq 1 ] && [ $ch_difficulty -eq 1 ]; then
  filterByDifficultyAndOS $difficulty $operation_system
elif [ $parameter_cond -eq 7 ]; then
  filterBySkills "$skill"
else
  help
fi
