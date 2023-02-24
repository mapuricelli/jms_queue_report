# JMS Queue Report

Tool di reportistica per l'estrazione - tramite la CLI WLST di Weblogic - valori a runtime per tutte le Destinazioni possibili di ogni Coda  presente nei Moduli JMS selezionati. 

### File di configurazione:

* conf/env.conf :

> fsda



########################################################################
################# Report Code JMS - Valori Correnti ####################
############################ Catena 3A #################################
########################################################################
#
#  - Per ogni Coda JMS presente nei Moduli:
#
#    * SystemModule-SCDP
#
#    (./conf/env.conf) --> array var MODULI_JMS)
#
#  - Estraggo i seguenti valori per tutte le Destinazioni possibili:
#
#    * Consumer correnti      (Consumers Current Count)
#    * Numero max di consumer (Consumers High Count)
#    * Consumer totali        (Consumers Total Count)
#    * Messaggi correnti      (Messages Current Count)
#    * Numero max di messaggi (Messages High Count)
#    * Messaggi in sospeso    (Messages Pending Count)
#
#  - Fatto! Invio i dati in allegato ai seguenti destinatari email:
#
#    * manuel.puricelli@consulenti.fastweb.it
#
#    (./conf/destinatari.conf))
#
#  - Log di questa esecuzione compressi e backuppati:
#
#    * ./spools/3A/SystemModule-SCDP/SystemModule-SCDP_3A_20230224_10.45.02.tar
#
########################################################################