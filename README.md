# JMS Queue Report

## Tool di reportistica per l'estrazione dei valori runtime delle Code JMS

> Per tutte le Destinazioni presenti nei Moduli JMS **selezionati** vengono estratti i seguenti valori a Runtime:

  * Consumer correnti      (Consumers Current Count)
  * Numero max di consumer (Consumers High Count)
  * Consumer totali        (Consumers Total Count)
  * Messaggi correnti      (Messages Current Count)
  * Numero max di messaggi (Messages High Count)
  * Messaggi in sospeso    (Messages Pending Count)

> L'estrazione viene formattata in 3 formati:

  * HTML con estensione **.html**
  * Comma Separated con estensione **.csv** (separatore pipe "|")
  * Tabella ascii con estensione **.txt** (comando unix *column*) 

> Essa viene poi compressa, backuppata sotto la directory ```spool/``` e inviata via mail.
  
## Prerequisiti

> Occorre che sulla macchina su cui si vuole installare **JMS Queue Report** ci sia già un'installazione funzionante di Weblogic WLST.

> E' anche necessario che l'Admin_Server specificato nella variabile ```${ADMIN_URL}``` *(vedi sezione [Configurazione](https://github.com/mapuricelli/jms_queue_report#configurazione))* sia in RUNNING.
  
## Installazione

> Eseguire i seguenti comandi da una shell Linux:

```bash
# Effettuare il download del pacchetto sw:
wget -q -O /tmp/jms_queue_report.tar.gz \
  https://github.com/mapuricelli/jms_queue_report/archive/refs/heads/main.tar.gz

# Estrarre il pacchetto nella ${HOME} dell'utente applicativo utilizzato per la WLST CLI:
cd ${HOME}
tar zxfv /tmp/jms_queue_report.tar.gz
rm -f  ${HOME}/jms_queue_report
ln -fs ${HOME}/jms_queue_report-main/ ${HOME}/jms_queue_report

```

## Configurazione

> Per ogni Environment desiderato creare un nuovo file di configurazione partendo dal template ```conf/env.Template.PRO``` .

> Esempio per un **ipotetico** Environment **SBTEST** in Ambiente **3B**:

> __Warning__ Attenzione: eseguire i seguenti comandi solo la prima volta per non sovrascrivere un eventualmente file già esistente.

```bash
# Duplico il template
# Attenzione: eseguire i seguenti comandi solo la prima volta per non sovrascrivere un eventualmente file già esistente.
cd ${HOME}/jms_queue_report/conf/
cp env.Template.PRO env.SBTEST.3B

```

> Editare il file ```conf/env.SBTEST.3B``` appena creato specificando gli **ipotetici** parametri desiderati.

> Esempio di cui sopra:

```bash
# Lista dei Moduli JMS interessati separati da spazio
export MODULI_JMS='My_JMS_Module'

# URL t3 di connessione a Weblogic e relativi utente/password amministrative
export ADMIN_URL='t3://sbtest.admin.3b.acme.com:7001'
export ADMIN_USER='weblogic'
export ADMIN_PASSWD='welcome1'

 # Lista destinatari per la mail di Reportistica separati da virgola
export DESTINATARI='tester.uno@acme.com,tester.due@acme.com,tl.uno@acme.com'

# Path dello script "setDomainEnv"
export SETDOMAINENV_PATH="/app/oss/bea-domains/sbtest-domain/bin/setDomainEnv.sh"
. ${SETDOMAINENV_PATH}

```

## Esecuzione

> Dare i permessi d'esecuzione necessari ed eseguire lo script ```start.sh```senza parametri per visualizzare gli Environment disponibili (il template viene skippato).

> Esempio di cui sopra:

```bash
cd ${HOME}/jms_queue_report/
chmod +x ./start.sh
chmod +x ./bin/uuencode
chmod +x ./bin/csv2html.sh
./start.sh

```

# Policy di Sicurezza

## Per segnalare un bug, una vulerabilità o per proporre un Enhancement

> Crea una [Nuova Issue](https://github.com/mapuricelli/jms_queue_report/issues/new)

#

###### *by [M. Puricelli - CM@Fastweb](https://github.com/mapuricelli/)*
