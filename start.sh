#!/bin/bash

export TMP_SPOOL="$(mktemp)" || exit 1
export TMP_ERR="$(mktemp)" || exit 1
trap 'rm -f ${TMP_SPOOL}* ${TMP_ERR}* ' EXIT

export SPOOL_DIR=$(readlink -f  $(dirname $0)/spools)
export CONF_DIR=$(readlink -f  $(dirname $0)/conf)
export LIB_DIR=$(readlink -f  $(dirname $0)/lib)
. ${LIB_DIR}/colori.conf

export JAVA_HOME=/app/oss3a/bea-wls-10.3.6/jrockit-jdk1.6.0_31-R28.2.3-4.1.0
export PATH=${PATH}:${JAVA_HOME}/jre/bin/

export TIMESTAMP=$(date "+%Y%m%d_%H.%M.%S")
export SPOOL_NAMING_CONV=
export MOD_SPOOL_DIR=

export ENV_CONF=
export ENV=
export CATENA=

function usage
{
  echo -e ""
  echo -e "- Parametri di Environment disponibili:"
  echo -e ""

  ls -1 ${CONF_DIR}/env.* | grep -v ${CONF_DIR}/env.Template.PRO | awk -F"." '{print $2"."$3}' | sort -u | while read C
  do
    echo -e "    ${0} -e ${FGVerdeChiaro}${C}${FGReset}"
  done
  
  echo -e ""

  exit 999
}

function missingEnv
{
  echo -e ""
  echo -e "- ${FGRossoChiaro}Attenzione${FGReset}"
  echo -e ""
  echo -e "    L'environment ${FGGiallo}${ENV}.${CATENA}${FGReset} non esiste"

  usage
}

function esciMale
{
  # $1 Codice di exit
  # $2 Messaggio di exit
  
  echo -e "#  - ${FGRossoChiaro}Fail${FGReset}: ${2}"
  echo -e "#"
  
  cat ${TMP_ERR} | while read ERR
  do
    echo -e "#    ${FGRossoChiaro}* ${ERR}${FGReset}"
  done
  
  echo -e "#"
  echo -e "#  - Exit Code ${FGRossoChiaro}${1}${FGReset}"
  echo -e "#"
  echo -e "########################################################################"
    
  exit ${1}
}

function go
{

  if [[ ${CATENA} != "" ]]; then

    echo -e
    echo -e "########################################################################"
	echo -e "########################### ${FGAzzurroChiaro}JMS Queue Report${FGReset} ###########################"
    echo -e "############################## ${FGGiallo}Catena ${CATENA}${FGReset} ###############################"
    echo -e "########################################################################"
    echo -e "#"
    echo -e "#  - Per tutte le Destinazioni presenti nei seguenti Moduli JMS:"
    echo -e "#"
	for MOD in "${MODULI_JMS_LIST[@]}"
    do
      echo -e "#    * ${FGVerdeChiaro}${MOD}${FGReset}"
	done
    echo -e "#"
    echo -e "#  - Estraggo i seguenti valori a Runtime:"
    echo -e "#"
    echo -e "#    * ${FGVerdeChiaro}Consumer correnti      ${FGReset}(Consumers Current Count)"
    echo -e "#    * ${FGVerdeChiaro}Numero max di consumer ${FGReset}(Consumers High Count)"
    echo -e "#    * ${FGVerdeChiaro}Consumer totali        ${FGReset}(Consumers Total Count)"
    echo -e "#    * ${FGVerdeChiaro}Messaggi correnti      ${FGReset}(Messages Current Count)"
    echo -e "#    * ${FGVerdeChiaro}Numero max di messaggi ${FGReset}(Messages High Count)"
    echo -e "#    * ${FGVerdeChiaro}Messaggi in sospeso    ${FGReset}(Messages Pending Count)"
    echo -e "#"

    # Lancio l'export dei dati tramite WLST
    java weblogic.WLST $(readlink -f  $(dirname $0))/bin/export.py 2> ${TMP_ERR} 1>  /dev/null

	if [[ $? -ne 0 ]]; then esciMale 888 "Errore nell'esecuzione dello script WLST!"; fi

    echo -e "#"
    echo -e "#  - Estrazione completata, contenuti compressi e backuppati :"

    SPOOL_NAMING_CONV="${CATENA}_${TIMESTAMP}"
	
    for MOD in "${MODULI_JMS_LIST[@]}"
    do

      MOD_SPOOL_DIR=${SPOOL_DIR}/${CATENA}/${ENV}/${MOD}
      mkdir -p ${MOD_SPOOL_DIR}/
	  MOD_FILENAME=${MOD}_${SPOOL_NAMING_CONV}

      # Riordino e creo il .csv ufficiale
	  (head -n 1 ${TMP_SPOOL}_${MOD} && tail -n +2 ${TMP_SPOOL}_${MOD} | sort) > ${MOD_SPOOL_DIR}/${MOD_FILENAME}.csv

      # Creo la versione html
      $(dirname $0)/bin/csv2html.sh ${MOD_SPOOL_DIR}/${MOD_FILENAME}.csv > ${MOD_SPOOL_DIR}/${MOD_FILENAME}.html
	  sed -i "s/{{TITOLO}}/<h1>JMS Queue Report<\/h1>/" ${MOD_SPOOL_DIR}/${MOD_FILENAME}.html
	  sed -i "s/{{SOTTOTITOLO}}/<h3>(${ENV} - ${CATENA})<\/h3>/" ${MOD_SPOOL_DIR}/${MOD_FILENAME}.html
	  sed -i "s/{{TITOLETTO}}/<h2>${MOD}<\/h2>/" ${MOD_SPOOL_DIR}/${MOD_FILENAME}.html

      # Creo la versione ascii table
      cat ${MOD_SPOOL_DIR}/${MOD_FILENAME}.csv | column -t -s "|" > ${MOD_SPOOL_DIR}/${MOD_FILENAME}.txt

      # Comprimo il tutto
      (cd ${MOD_SPOOL_DIR}/ && tar -cf $(basename ${MOD_SPOOL_DIR}/${MOD_FILENAME}).tar $(basename ${MOD_SPOOL_DIR}/${MOD_FILENAME}).*)
	  
      echo -e "#"
      echo -e "#    ${FGAzzurroChiaro}${MOD_SPOOL_DIR}/${FGReset}"
      echo -e "#"
      echo -e "#    --> ${FGVerdeChiaro}${MOD_FILENAME}.tar${FGReset}"

    done

    echo -e "#"
    echo -e "#  - Invio i dati in allegato via email ai seguenti destinatari:"
    echo -e "#"
    for DEST in "${DESTINATARI_LIST[@]}"
    do
      echo -e "#    * ${FGAzzurroChiaro}${DEST}${FGReset}"
    done

    # Concateno gli allegati e mando mail
    ( 
      echo "Per ogni Coda JMS presente nei Moduli selezionati sono stati estratti i seguenti valori per tutte le Destinazioni possibili:"
      echo ""
      echo "  * Consumer correnti      (Consumers Current Count)"
      echo "  * Numero max di consumer (Consumers High Count)"
      echo "  * Consumer totali        (Consumers Total Count)"
      echo "  * Messaggi correnti      (Messages Current Count)"
      echo "  * Numero max di messaggi (Messages High Count)"
      echo "  * Messaggi in sospeso    (Messages Pending Count)"
      echo ""
      echo "In allegato i report prodotti."
      echo ""
      echo "Manuel"
      echo "347 7098296"
	  
	  for MOD in "${MODULI_JMS_LIST[@]}"
      do
        MOD_SPOOL_DIR=${SPOOL_DIR}/${CATENA}/${ENV}/${MOD}
		MOD_FILENAME=${MOD}_${SPOOL_NAMING_CONV}
		
        $(dirname $0)/bin/uuencode ${MOD_SPOOL_DIR}/${MOD_FILENAME}.tar $(basename ${MOD_SPOOL_DIR}/${MOD_FILENAME}.tar)
      done

    ) | mailx -s "[${ENV} - ${CATENA}] JMS Queue Report" ${DESTINATARI}

    rm -f ${SPOOL_DIR}/*/*/*/*.csv
    rm -f ${SPOOL_DIR}/*/*/*/*.txt
    rm -f ${SPOOL_DIR}/*/*/*/*.html

  else
    usage
  fi
}

while getopts "he:" Option
do
  case $Option in
    e )
	  ENV=$(echo ${OPTARG} | cut -d. -f1)
	  CATENA=$(echo ${OPTARG} | cut -d. -f2)
      ;;
    * )
      usage
      ;;
    ? )
      usage
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  usage
fi

if [[ -f ${CONF_DIR}/env.${ENV}.${CATENA} ]]; then

  ENV_CONF=${CONF_DIR}/env.${ENV}.${CATENA}
  . ${ENV_CONF}

  read -a MODULI_JMS_LIST <<< ${MODULI_JMS}
  read -a DESTINATARI_LIST <<< ${DESTINATARI}

  go
  echo -e "#"
  echo -e "########################################################################"
  echo -e ""

else
  missingEnv
fi
