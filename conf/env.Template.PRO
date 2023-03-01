# Prefisso per il Subject della mail di Reportistica
export MAIL_SBJ_PREFIX=WL_PRO

# Lista dei Moduli JMS interessati separati da spazio
export MODULI_JMS='MyModule1 MyModule2'

# URL t3 di connessione a Weblogic e relativi utente/password amministrative
export ADMIN_URL='t3://myt3.acme.com:6666'
export ADMIN_USER='weblogic'
export ADMIN_PASSWD='welcome1'

# Lista destinatari per la mail di Reportistica separati da virgola
export DESTINATARI='none1@acme.com,none2@acme.com'

# Path dello script "setDomainEnv"
export SETDOMAINENV_PATH="/app/oss/bea-domains/wl_pro_domain/bin/setDomainEnv.sh"
. ${SETDOMAINENV_PATH}
