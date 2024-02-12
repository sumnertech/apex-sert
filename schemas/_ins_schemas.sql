create user sert_pub identified by "SecurityisHard123!!!" default tablespace users
/

create user sert_core identified by "SecurityisHard123!!!" default tablespace users
/

create user sert_rest identified by "SecurityisHard123!!!" default tablespace users
/

alter user sert_core quota unlimited on users
/

alter user sert_pub quota unlimited on users
/
