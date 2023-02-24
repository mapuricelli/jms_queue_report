import sys
import os

MODULI_JMS = os.environ.get("MODULI_JMS").split(" ")

from weblogic.jms.extensions import JMSMessageInfo
from javax.jms import TextMessage
from javax.jms import ObjectMessage

TMP_SPOOL = os.environ["TMP_SPOOL"]
URL = os.environ["URL"]
USER = os.environ["USER"]
PASSWD = os.environ["PASSWD"]

connect(USER,PASSWD,URL);

for MOD in MODULI_JMS:

  sys.stdout = open(TMP_SPOOL+'_'+MOD, 'w')

  print('Code (Destinazioni)|Consumer correnti|Numero max di consumer|Consumer totali|Messaggi correnti|Numero max di messaggi|Messaggi in sospeso');

  servers = domainRuntimeService.getServerRuntimes();
  if (len(servers) > 0):
    for server in servers:
      jmsRuntime = server.getJMSRuntime();
      jmsServers = jmsRuntime.getJMSServers();
      for jmsServer in jmsServers:
        destinations = jmsServer.getDestinations();
        for destination in destinations:
          if MOD in destination.getName() :
            print(destination.getName().split('@')[1] + ' (' + destination.getName().split('@')[0] + ')|' + str(destination.getConsumersCurrentCount()) + '|' + str(destination.getConsumersHighCount()) + '|'+ str(destination.getConsumersTotalCount()) + '|' + str(destination.getMessagesCurrentCount()) + '|' + str(destination.getMessagesHighCount())+ '|' + str(destination.getMessagesPendingCount()))

exit()
