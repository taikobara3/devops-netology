# Clickhouse

## Что делает playbook:

Playbook разворачивает на заданном хосте приложения:
- сlickhouse-client
- clickhouse-server
- clickhouse-common
- vector
Запускает clickhouse-server, создает базу данных

## Параметры
- IP целевого хоста надо задать в prod.yml, там же указать пользователя ssh для которого настроен вход по сертификату, приватный ключ которого указывается здесь же
- версии и архитектура пакетов указываются в vars.yml

## Теги
- clickhouse
- vector
