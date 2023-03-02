#!/bin/bash

export TMP_SPOOL="$(mktemp)" || exit 1
export TMP_ERR="$(mktemp)" || exit 1
trap 'rm -f ${TMP_SPOOL}* ${TMP_ERR}* ' EXIT

export SCRIPT_DIR=$(readlink -f  $(dirname $0))
export SPOOL_DIR="${SCRIPT_DIR}/spools"
export CONF_DIR=$"${SCRIPT_DIR}/conf"
export LIB_DIR="${SCRIPT_DIR}/lib"
export BIN_DIR="${SCRIPT_DIR}/bin"
. ${LIB_DIR}/colori.conf

export TIMESTAMP=$(date "+%Y%m%d_%H.%M.%S")

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

function download
{
  echo -e  "#"
  echo -en "#  - Scarico l'archivio aggiornato da GitHub."
  curl -s --connect-timeout 3 \
    --output /tmp/jms_queue_report-main.zip \
    --location https://github.com/mapuricelli/jms_queue_report/archive/refs/heads/main.zip

  if [[ $? -ne 0 ]]; then
    echo -e ""
    echo -e "#"
    esciMale 888 "Impossibile scaricare l'archivio da GitHub.\n#          Verificare che questa macchina abbia accesso a Internet\n#          in caso contrario:\n#\n#          * Scaricare l'archivio manualmente tramite browser da:\n#\n#            https://github.com/${FGMarrone}mapuricelli${FGReset}/${FGGiallo}jms_queue_report/archive/refs/heads/main.zip${FGReset}\n#\n#          * Posizionarlo sotto ${FGGiallo}/tmp/jms_queue_report-main.zip${FGReset} e rilanciare questo script."
  else
    echo -e " ${FGVerdeChiaro}OK${FGReset}"
  fi
}

function checkPresent
{  
  if [[ -f /tmp/jms_queue_report-main.zip ]]; then
  
    echo -e "#"
    echo -e "#  - ${FGGiallo}Attenzione${FGReset}: l'archivio software e' gia' presente in questa versione:"
    echo -e "#"
    
    md5sum /tmp/jms_queue_report-main.zip | head -1 | while read MD5
    do
      echo -e "#      ${FGGiallo}$(echo ${MD5} | awk -F" " {'print $1'})${FGReset} $(echo ${MD5} | awk -F" " {'print $2'})"
    done
    
    echo -e  "#"
    echo -e  "#    Vuoi sovrascriverlo?"
    echo -en "#    (Y/n) "
    
    while read YESNO
    do
      if [[ "${YESNO}" == "" || "${YESNO}" == "y" || "${YESNO}" == "Y" ]]; then
        download
        break;
      
      elif [[ "${YESNO}" == "n" || "${YESNO}" == "N" ]]; then
        break;

      else
        echo -en "#    (Y/n) "
      fi
    done
  
  else
  
    download
  
  fi
  
  if [[ -f /tmp/jms_queue_report-main.zip ]]; then
    go
  fi
}

function go
{
  
  echo -e  "#"
  echo -en "#  - Estraggo l'archivio"
  
  cd ${HOME} && unzip -oq /tmp/jms_queue_report-main.zip
  
  if [[ $? -ne 0 ]]; then
    echo -e ""
    echo -e "#"
    esciMale 888 "Impossibile estrarre l'archivio nella ${FGGiallo}\${HOME}${FGReset}.\n#          Verificare i permessi su file e directory."
  else  
    echo -e  " ${FGVerdeChiaro}OK${FGReset}"
    echo -en "#  - Aggiungo i permessi di esecuzione dove necessario"
    chmod +x ${SCRIPT_DIR}/start.sh
    rm -f    ${SCRIPT_DIR}/inst-update.sh
    chmod +x ${BIN_DIR}/uuencode
    chmod +x ${BIN_DIR}/csv2html.sh
    echo -e  " ${FGVerdeChiaro}OK${FGReset}"
    echo -e  "#"
  fi
   
  echo -e "#"
  echo -e "#  - Update terminato, vai alla directory d'installazione:"
  echo -e "# "
  echo -e "#      cd ${FGMarrone}${HOME%/}/${FGVerdeChiaro}jms_queue_report${FGReset}/"
  echo -e "# "
  echo -e "#  - Per ulteriori info fai riferimento alla guida su GitHub:"
  echo -e "# "
  echo -e "#      ${FGiallo}https://github.com/${FGMarrone}mapuricelli${FGReset}/${FGGiallo}jms_queue_report#readme${FGReset}"
  echo -e "#"
  echo -e "########################################################################"
  
}

echo -e
echo -e "########################################################################"
echo -e "########################### ${FGAzzurroChiaro}JMS Queue Report${FGReset} ###########################"
echo -e "######################## ${FGGiallo}Aggiornamento Software${FGReset} ########################"
echo -e "########################################################################"
echo -e "#"

checkPresent