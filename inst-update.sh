#!/bin/bash

export TMP_SPOOL="$(mktemp)" || exit 1
export TMP_ERR="$(mktemp)" || exit 1
trap 'rm -f ${TMP_SPOOL}* ${TMP_ERR}* ' EXIT

export SCRIPT_DIR=$(readlink -f  $(dirname $0))
export SPOOL_DIR="${SCRIPT_DIR}/spools"
export CONF_DIR=$"${SCRIPT_DIR}/conf"
export LIB_DIR="${SCRIPT_DIR}/lib"
export BIN_DIR="${SCRIPT_DIR}/bin"
export INSTALL_DIR="${HOME}"
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
  echo -e  "#  - Scarico l'archivio aggiornato dal GitHub:"
  echo -e  "#"
  echo -en "#      ${FGiallo}https://github.com/${FGMarrone}mapuricelli${FGReset}/${FGGiallo}jms_queue_report/${FGReset}"
  curl -s --connect-timeout 3 \
    --output /tmp/jms_queue_report.tar.gz \
    --location https://github.com/mapuricelli/jms_queue_report/archive/refs/heads/main.tar.gz

  if [[ $? -ne 0 ]]; then
    echo -e ""
    echo -e "#"
    esciMale 888 "Impossibile scaricare l'archivio.\n#          Verificare che questa macchina abbia accesso a Internet.\n#          In caso contrario:\n\n#          * Scaricare l'archivio software manualmente\n#          * Posizionarlo sotto ${FGGiallo}/tmp/jms_queue_report.tar.gz${FGReset}\n#          * Rilanciare questo script."
  else
    echo -e "              ${FGVerdeChiaro}OK${FGReset}"
  fi
}

function checkPresent
{  
  if [[ -f /tmp/jms_queue_report.tar.gz ]]; then
  
    echo -e "#"
    echo -e "#  - ${FGGiallo}Attenzione${FGReset}: l'archivio software e' gia' presente in questa versione:"
    echo -e "#"
    
    md5sum /tmp/jms_queue_report.tar.gz | head -1 | while read MD5
    do
      echo -e "#     ${FGGiallo}$(echo ${MD5} | awk -F" " {'print $1'})${FGReset} $(echo ${MD5} | awk -F" " {'print $2'})"
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
  
  if [[ -f /tmp/jms_queue_report.tar.gz ]]; then
    go
  fi
}

function go
{
  
  echo -e  "#"
  echo -e "#  - Mi porto nella ${FGVerdeChiaro}$(echo ${INSTALL_DIR} | sed -e 's/$/\//')${FGReset} ed estraggo i file"
  
  cd ${INSTALL_DIR} && tar zxf /tmp/jms_queue_report.tar.gz
  
  if [[ $? -ne 0 ]]; then
    echo -e ""
    echo -e "#"
    esciMale 888 "Impossibile estrarre l'archivio nella ${FGGiallo}\${INSTALL_DIR}${FGReset}.\n#          Verificare i permessi su file e directory."
  else  
    echo -e "#    ${FGVerdeChiaro}OK${FGReset}"
    echo -e "#"
    
    echo -e "#  - Aggiungo i permessi di esecuzione dove necessario"
    rm -f  ${INSTALL_DIR}/jms_queue_report
    ln -fs ${INSTALL_DIR}/jms_queue_report-main/ ${INSTALL_DIR}/jms_queue_report
    chmod +x ${SCRIPT_DIR}/start.sh
    rm -f    ${SCRIPT_DIR}/update.sh
    chmod +x ${SCRIPT_DIR}/inst-update.sh
    chmod +x ${BIN_DIR}/uuencode
    chmod +x ${BIN_DIR}/csv2html.sh
    echo -e "#    ${FGVerdeChiaro}OK${FGReset}"
    echo -e "#"
  fi
  
  echo -e  "#"
  echo -e "########################################################################"
  
}

function chiediInstallDir
{
  echo -e  "#"
  echo -e  "#    In quale directory vuoi installare/aggiornare?"
  echo -e  "#"
  echo -e  "#    (Default: ${FGRossoChiaro}$(echo ${HOME} | sed -e 's/$/\//')${FGReset})"
  echo -e  "#"
  echo -en "#    > "
  
  while read TMP_INSTALL_DIR
  do
  
    if [[ "${TMP_INSTALL_DIR}" == "" ]]; then TMP_INSTALL_DIR=${INSTALL_DIR}; fi
  
    if [[ -d "${TMP_INSTALL_DIR}" ]]; then
      INSTALL_DIR=${TMP_INSTALL_DIR}
      break;
    
    else
      echo $TMP_INSTALL_DIR
      exit
      mkdir ${TMP_INSTALL_DIR} && INSTALL_DIR=${TMP_INSTALL_DIR}  || esciMale 485 "Impossibile creare la directory:\n\n#          * ${FGRossoChiaro}${INSTALL_DIR}${FGReset}\n"
      echo -en "#    > "
    fi

    download
    
  done
}

echo -e
echo -e "########################################################################"
echo -e "########################### ${FGAzzurroChiaro}JMS Queue Report${FGReset} ###########################"
echo -e "######################## ${FGGiallo}Aggiornamento Software${FGReset} ########################"
echo -e "########################################################################"
echo -e "#"

chiediInstallDir && checkPresent