# Clickhouse

## Что делает playbook:

Playbook разворачивает на заданных хостах приложения:
- сlickhouse-client
- clickhouse-server
- clickhouse-common
- vector
- lighthouse
Запускает clickhouse-server, создает базу данных
Запускает nginx (доступ к странице lighthouse по адресу http://[адрес_хоста_lighthouse]/lighthouse-master)

## Параметры
- IP целевого хоста надо задать в prod.yml, там же указать пользователя ssh для которого настроен вход по сертификату, приватный ключ которого указывается здесь же
- версии и архитектура пакетов указываются в vars.yml

## Теги
- clickhouse
- vector
- lighthouse
