#!/bin/bash

PORT=3000

case $1 in
  init)
    $0 up --build
    ;;

  port)
    shift
    echo Server hosted on http://`$0 compose port app ${PORT} 2> /dev/null`
    ;;

  up)
    shift
    go mod tidy
    version=`git describe --tags --dirty --always`
    RELEASE_TAG=${version} docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --remove-orphans "$@"
    $0 port
    ;;
  
  stop)
    shift
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml stop "$@"
    ;;

  down)
    shift
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml down --volumes "$@"
    ;;

  restart)
    shift
    go mod tidy
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml restart ${1:-app web}
    ;;

  staging)
    shift
    go mod tidy
    docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d --build --remove-orphans "$@"
    $0 port
    ;;

  ps)
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml "$@"
    ;;

  logs)
    shift
    service=${1:-app}
    shift
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml logs --tail 100 -f "$@" ${service}
    ;;

  test)
    shift
    $0 test-app
    $0 test-web
    ;;

  test-app)
    shift
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec -e app go test ./... "$@"
    ;;

  test-web)
    shift
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec -e web npm test "$@"
    ;;

  shell)
    shift
    service=${1:-app}
    shift
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec ${service} ${@:-bash}
    ;;

  compose)
    shift
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml "$@"
    ;;

  npm)
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec web "$@"
    ;;
  npx)
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec web "$@"
    ;;

  ping)
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec app curl 0:${PORT}/ping
    echo
    ;;

  *)
    echo "usage: $0 <command>"
    echo
    echo "Stack specific commands:"
    echo "init             initialize project and run stack"
    echo "port             show port for stack"
    echo "up [service]     run stack (try $0 up --build)"
    echo "stop [service]   stop stack"
    echo "down [service]   tear down stack"
    echo "restart [service] restart app"
    echo "staging          start staging stack"
    echo "ps               list running docker containers"
    echo "logs [service]   show app logs"
    echo "test <args>      run tests"
    echo
    echo "Helper commands:"
    echo "shell [service]  shell prompt"
    echo "compose <args>   docker-compose commands"
    echo "npm <args>       npm commands"
    echo "npx <args>       npx commands"
    ;;

esac
