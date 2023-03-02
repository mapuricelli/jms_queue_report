#!/bin/bash

export INSTALL_DIR="${HOME}"
. lib/colori.conf

function usage
{
  echo -e ""
  echo -e "    ${0}"
  echo -e ""

  exit 999
}

function esciMale
{
  # $1 Codice di exit
  # $2 Messaggio di exit
  # $3 Messaggio di errore d'origine
  
  echo -e "#  - ${FGRossoChiaro}Fail${FGReset}: ${2}"
  
  if [[ -n "${3}" ]]; then
    echo -e "#"
    echo ${3} | while read ERR
    do
      echo -e "#    ${FGRossoChiaro}* ${ERR}${FGReset}"
    done
  fi
  
  echo -e "#"
  echo -e "#  - Exit Code ${FGRossoChiaro}${1}${FGReset}"
  echo -e "#"
  echo -e "########################################################################"
    
  exit ${1}
}


function go
{
  if [[ -d ${INSTALL_DIR} ]]; then
    
    cd ${INSTALL_DIR}/
    unzip -oq /tmp/jms_queue_report-main.zip
    rm -f  ./jms_queue_report
    ln -fs ./jms_queue_report-main/ ./jms_queue_report
    cd ./jms_queue_report
    chmod +x start.sh
    chmod +x update.sh
    rm    -f install.sh
    find . -name .gitignore -exec rm -f {} \;
    chmod +x bin/uuencode
    chmod +x bin/csv2html.sh
    
  else  
    echo -e "#"
    esciMale 888 "Impossibile estrarre l'archivio nella ${FGGiallo}\${INSTALL_DIR}${FGReset}.\n#          Verificare i permessi su file e directory."
    
  fi
   
  echo -e "#"
  echo -e "#  - Installazione terminata, vai alla directory d'installazione:"
  echo -e "# "
  echo -e "#      cd ${FGMarrone}${INSTALL_DIR%/}/${FGVerdeChiaro}jms_queue_report${FGReset}/"
  echo -e "# "
  echo -e "#  - Per effettuare la configurazione segui la guida su GitHub:"
  echo -e "# "
  echo -e "#      ${FGiallo}https://github.com/${FGMarrone}mapuricelli${FGReset}/${FGGiallo}jms_queue_report#configurazione${FGReset}"
  echo -e "#"
  echo -e "########################################################################"
  
}

function chiediInstallDir
{
  echo -e  "#"
  echo -e  "#    In quale directory (${FGMarrone}\${INSTALL_DIR}${FGReset}) vuoi installare JMS Queue Report?"
  echo -e  "#"
  echo -e  "#    (Default home directory: ${FGMarrone}$(echo ${HOME} | sed -e 's/$/\//')${FGReset})"
  echo -e  "#"
  echo -en "#    > "
  
  while read TMP_INSTALL_DIR
  do
  
    if [[ "${TMP_INSTALL_DIR}" == "" ]]; then
      TMP_INSTALL_DIR=${INSTALL_DIR}
    fi
  
    if [[ -d "${TMP_INSTALL_DIR}" ]]; then
      INSTALL_DIR=${TMP_INSTALL_DIR}
      break;
    
    else
      mkdir ${TMP_INSTALL_DIR} && INSTALL_DIR=${TMP_INSTALL_DIR}  || esciMale 485 "Impossibile creare la directory:\n\n#          * ${FGRossoChiaro}${INSTALL_DIR}${FGReset}\n"
      break;
    fi
    
  done
  
  INSTALL_DIR="${INSTALL_DIR%/}/"

}

echo -e
echo -e "########################################################################"
echo -e "########################### ${FGAzzurroChiaro}JMS Queue Report${FGReset} ###########################"
echo -e "######################## ${FGGiallo}Aggiornamento Software${FGReset} ########################"
echo -e "########################################################################"
echo -e "#"

chiediInstallDir && go
echo