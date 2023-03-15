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

> Essa viene poi compressa, backuppata sotto la directory ```spools/``` e inviata via mail.
  
## Prerequisiti

> Piattaforme Linux x86.

> Occorre che sulla macchina su cui si vuole installare **JMS Queue Report** ci sia già un'installazione funzionante di Weblogic WLST.

> E' necessario che l'**Admin Server** specificato nella variabile ```${ADMIN_URL}``` *(vedi sezione [Configurazione](https://github.com/mapuricelli/jms_queue_report#configurazione))* sia in RUNNING.

> Verificare infine che sia installata una versione recente di ```mailx``` che accetti il flag ```-a``` per gli allegati.
  
## Prima Installazione

> Scaricare il [Pacchetto ZIP](https://github.com/mapuricelli/jms_queue_report/archive/refs/heads/main.zip), depositarlo nella ```/tmp/``` ed eseguire i seguenti comandi:

```bash
cd /tmp/
unzip -q -jod /tmp/ jms_queue_report-main.zip jms_queue_report-main/lib/colori.conf
unzip -q -jod /tmp/ jms_queue_report-main.zip jms_queue_report-main/install
chmod +x ./install
./install

```

> Per le successive installazioni e/o update seguire la procedura di [Update](https://github.com/mapuricelli/jms_queue_report#updates).

## Configurazione

> Per ogni Environment desiderato creare un nuovo file di configurazione partendo dal template ```conf/env.Template.PRO``` .

> Esempio per un **ipotetico** Environment **SBTEST** in Ambiente **3B**:

> :fire::skull: Attenzione: eseguire i seguenti comandi solo la prima volta per non sovrascrivere un eventuale file già esistente.

```bash
# Duplico il template
# Attenzione: eseguire i seguenti comandi solo la prima volta per non sovrascrivere un eventuale file già esistente.
cd ${HOME}/jms_queue_report/conf/
cp env.Template.PRO env.SBTEST.3B

```

> Nel file di configurazione appena creato valorizzare dunque le seguenti variabili in base al proprio ambiente d'installazione.

> Esempio per l'ipotetico file ```conf/env.SBTEST.3B```:

```bash
export MAIL_SBJ_PREFIX=SB_TEST
export MODULI_JMS='My_JMS_Module'
export ADMIN_URL='t3://sbtest.admin.3b.acme.com:7001'
export ADMIN_USER='weblogic'
export ADMIN_PASSWD='welcome1'
export DESTINATARI='tester.uno@acme.com,tester.due@acme.com,tl.uno@acme.com'
export SETDOMAINENV_PATH="/app/oss/bea-domains/sbtest-domain/bin/setDomainEnv.sh"

```

> Per specificare un path custom per il comando ```mailx``` decommentare ed aggiornare la variabile ```${CUSTOM_MAILX}``` nel file di conf ```${HOME}/jms_queue_report/.jqr```.

```bash
CUSTOM_MAILX="${HOME}/bin/mailx"
```

CUSTOM_MAILX="${HOME}/bin/mailx"

## Esecuzione

> Eseguire lo script ```jqr``` senza parametri per visualizzare gli Environment disponibili (il template viene skippato).

> Esempio:

```bash
cd ${HOME}/jms_queue_report/
./jqr

```
  
## Updates

> Eseguire lo script ```update``` senza parametri e seguire le istruzioni a video.

```bash
cd ${HOME}/jms_queue_report/
./update

```

# Policy di Sicurezza

## Per segnalare un bug, una vulerabilità o per proporre un Enhancement

> Crea una [Nuova Issue](https://github.com/mapuricelli/jms_queue_report/issues/new)

#

###### *by [M. Puricelli - CM@Fastweb](https://github.com/mapuricelli/)*

