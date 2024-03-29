# Домашнее задание к занятию «Микросервисы: принципы»

Вы работаете в крупной компании, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps-специалисту необходимо выдвинуть предложение по организации инфраструктуры для разработки и эксплуатации.

## Задача 1: API Gateway 

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:
- маршрутизация запросов к нужному сервису на основе конфигурации,
- возможность проверки аутентификационной информации в запросах,
- обеспечение терминации HTTPS.

Обоснуйте свой выбор.

 Решение | Конфигурация  | Аутентификация | Терминация HTTPS | Сайт| Язык       | Лицензия | Санкционные риски |
|---|---------------|---|---|---|------------|---|---|
| WSO2 API Manager | +             | + | + |https://wso2.com/api-manager/|            |Проприетарная| Средние |
| Gravitee | +(БД)         | + | + |https://www.gravitee.io//| LUA        |Проприетарная| Средние |
| Kong | +(БД)         | + | + |https://konghq.com/kong/| LUA        |Apache 2.0| Низкие |
| Tyk.io | +(файлы,JSON) | + | + |https://tyk.io/| GO         |MPL| Средние |
| Express Gateway | +(файлы,JSON) | + | + |https://www.express-gateway.io/| JavaScript |Apache 2.0| Низкие |
| Apache APISIX | +             | + | + |https://apisix.apache.org/| LUA        |Apache 2.0| Низкие |
| APIGee | +             | +(ограничено) | + |https://cloud.google.com/apigee/| JAVA       |Проприетарная| Высокие |
| F5 NGINX Plus | +             | + | + |https://www.nginx.com/products/nginx/api-gateway/| C          |Проприетарная| Высокие |
| KrakenD | +(файлы,JSON) | + | + |https://www.krakend.io/| GO         |Apache 2.0| Низкие |

Все представленные в таблице решения отвечают требованиям, описанным в задаче.

Окончательный выбор может зависеть от условий, не освещенных в постановке задачи. Важными критериями представляются - штат специалистов, компетенции в использовании языков, в каких условиях будет реализовываться продукт (внутреннее решение, или ориентированное на широкую аудиторию), необходимость дальнейшего масштабирования, бюджет.

При ориентировании на self-hosted решения, наиболее оптимальным по большинству критериев будет, на мой взгляд, KrakenD (развертываение в docker, возможность расширять его возможности на разных языках программирования) или Kong (распространенное свободное решение, в основе которого лежит также хорошо известный и документированный nginx) - простота развертывания, конфигурации, достаточно широкие возможности при использовании бесплатных версий.

Среди "облачных", в настоящее время - скорее всего, - WSO2 API Manager, либо основанные на нем отечественные продукты. Использование других решений влечет за собой высокие санкционные риски.

## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:
- поддержка кластеризации для обеспечения надёжности,
- хранение сообщений на диске в процессе доставки,
- высокая скорость работы,
- поддержка различных форматов сообщений,
- разделение прав доступа к различным потокам сообщений,
- простота эксплуатации.

Обоснуйте свой выбор.

|Решение               | Сайт                            | Поддержка кластеризации | Хранение на диске |    Скорость     | Форматы сообщений | Разделение прав |    Простота конфигурации     |
|--------------------------|------------------------------------|:-----------------------:|:-----------------:|:---------------:|:-----------------:|:---------------:|:----------------------------:|
| RabbitMQ                 | https://www.rabbitmq.com/          |            +            |         +         |    Медленно     |         +         |        +        |              +               |
| ActiveMQ Artemis         | http://activemq.apache.org/artemis/ |            +            |         +         | Быстрее средней |         +         |        +        | Может представлять сложность |
| Redis streams            | https://redis.io/                  |            +            |         +         |     Быстрая     |         +         |        -        |              +               |
| Apache Pulsar            | https://pulsar.apache.org/         |      + (ZooKeeper)      |  + (BookKeeper)   |      Быстрая       |         +         |        +        |              -               |
| RocketMQ                 | https://rocketmq.apache.org/       |            +            |         +         |      Быстрая       |         +         |        +        |              -               |
| Kafka                    | https://kafka.apache.org/          |            +            |         +         |    Быстрая    |         +         |        +        |              -               |

Как следует из таблицы, решения удовлетворяющего на 100% всем поставленным в задаче условиям нет.

Окончательное решение должно приниматься исходя из специфики задачи. Например, если ожидается большой объем сообщений - наиболее очевидным выбором будет Kafka

Наиболее универсальное в рамках поставленных требований решение - RabbitMQ, но у него сравнительно невысокая скорость.