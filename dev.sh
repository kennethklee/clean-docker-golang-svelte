#!/bin/bash

# Config
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
    (cd app && go mod tidy)
    version=`git describe --tags --dirty --always`
    VERSION=${version} docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --remove-orphans "$@"
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
    (cd app && go mod tidy)
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml restart ${1:-app web}
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

  staging)
    shift
    (cd app && go mod tidy)
    version=`git describe --tags --dirty --always`
    VERSION=${version} docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d --build --remove-orphans "$@"
    $0 port
    ;;
  
  build)
    shift
    # ensure IMAGE is set
    if [ -z "${IMAGE}" ]; then
      echo "IMAGE is not set. Set the target docker image name like 'IMAGE=myusername/myproject:1.0.0 ./dev.sh build'"
      exit 1
    fi
    (cd app && go mod tidy)
    version=`git describe --tags`
    VERSION=${version} docker-compose build app
    ;;


  # Helper commands
  ps)
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml "$@"
    ;;

  logs)
    shift
    service=${1:-app}
    shift
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml logs --tail 100 -f "$@" ${service}
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

  # Optional:
  # db)
  #   shift
  #   docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec db ${@:-psql -U postgres}
  #   ;;
  #
  # smoke)
  #   docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec app curl 0:${PORT}/ping
  #   echo
  #   ;;

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
    echo "test <args>      run tests"
    echo "staging          start staging stack"
    echo "build            builds final image. IMAGE must be set"
    echo
    echo "Helper commands:"
    echo "ps               list running docker containers"
    echo "logs [service]   show app logs"
    echo "shell [service]  shell prompt"
    echo "compose <args>   docker-compose commands"
    echo "npm <args>       npm commands"
    echo "npx <args>       npx commands"
    
    # Optional:
    # echo "db               psql prompt"
    # echo "smoke            smoke test"
    ;;

esac
