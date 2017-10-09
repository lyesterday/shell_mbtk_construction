#!/bin/bash
#for input cmd
INPUT_CMD=DEFAULT
#end for input
#for compile
COMPILE_FILE=DEFAULT
COMPILE_PATH=DEFAULT
COMPILE_CMD=DEFAULT
COMPILE_SH=DEFAULT
#end for compile

#for putput
BIN_FILE=DEFAULT
BIN_PUT_PATH=DEFAULT
#end for output

typeset -u INPUT_CMD
SHELL_ROOT_PATH=$(pwd)

function extend_sh_cb()
{
    echo "extend compile function call back is devolopment!"
    return
}

function extend_sh()
{
   if [ -n "$COMPILE_SH" ]
    then
     echo "do extend compile file $COMPILE_SH"
     source $SHELL_ROOT_PATH/$COMPILE_SH
     extend_sh_cb
     #exit 0
    fi
  #echo "==================================================================================================================="
  return
}

function input()
{
  COMPILE_TEST=`sed -n '/COMPILE_TEST=/'p env.dat | sed 's/COMPILE_TEST=//'`
  COMPILE_DEVLOP=`sed -n '/COMPILE_DEVOLOPMENT=/'p env.dat | sed 's/COMPILE_DEVOLOPMENT=//'`
  if [ -z "$1" ]
  then
    echo -e "project can selct:$COMPILE_TEST\nproject is devoloping:$COMPILE_DEVLOP"
    read -p "input: " INPUT_CMD
  else
    INPUT_CMD=$1
  fi
}

function source_env()
{
    COMPILE_PRJ=`echo ${INPUT_CMD:0:6}`
    SUPPORT_PROJECT=`sed -n '/SUPPORT_PROJECT=/'p env.dat | sed 's/SUPPORT_PROJECT=//'`
    if [[ $SUPPORT_PROJECT != *$COMPILE_PRJ* ]]
    then
      echo "project error"
      exit 0
    fi
    VERSION_SUPPORT=`sed -n '/'"$COMPILE_PRJ"_SUPPORT'=/'p env.dat | sed 's/'"$COMPILE_PRJ"_SUPPORT'=//'`
    if [[ $SUPPORT_PROJECT != *$1* ]]
    then
      echo "version error"
      exit 0
    fi
    COMPILE_SH=`sed -n '/'"$COMPILE_PRJ"_SH'=/'p env.dat | sed 's/'"$COMPILE_PRJ"_SH'=//'`
    if [ -n "$COMPILE_SH" ]
    then
     extend_sh $1
     #exit 0
    fi
    COMPILE_PATH="`sed -n '/'"$INPUT_CMD"_PATH'=/'p env.dat | sed 's/'"$INPUT_CMD"_PATH'=//'`""`sed -n '/'"$COMPILE_PRJ"_KERNELPATH'=/'p env.dat | sed 's/'"$COMPILE_PRJ"_KERNELPATH'=//'`"

    COMPILE_FILE=$COMPILE_PATH"`sed -n '/'"$COMPILE_PRJ"_COMPILE_FILE'=/'p env.dat | sed 's/'"$COMPILE_PRJ"_COMPILE_FILE'=//'`"

    COMPILE_CMD=`sed -n '/'"$COMPILE_PRJ"_COMPILE_CMD'=/'p env.dat | sed 's/'"$COMPILE_PRJ"_COMPILE_CMD'=//'`
    
    BIN_FILE=`sed -n '/'"$COMPILE_PRJ"_BINFILE'=/'p env.dat | sed 's/'"$COMPILE_PRJ"_BINFILE'=//'`

    BIN_PUT_PATH=`sed -n '/'"$COMPILE_PRJ"_OUTPUT_PATH'=/'p env.dat | sed 's/'"$COMPILE_PRJ"_OUTPUT_PATH'=//'`

    echo -e "COMPILE_SH:$COMPILE_SH\nCOMPILE_PRJ:$COMPILE_PRJ\nINPUT_CMD:$INPUT_CMD\nCOMPILE_CMD:$COMPILE_CMD\nCOMPILE_FILE:$COMPILE_FILE\nBIN_FILE:$BIN_FILE\nBIN_PUT_PATH:$BIN_PUT_PATH"

    if [ -z "$COMPILE_FILE" -o -z "$COMPILE_CMD" -o -z "$BIN_FILE" -o -z "$BIN_PUT_PATH" -o -z "$COMPILE_PATH" ]
    then
      echo "cannot source the compile "
      exit 0
    fi
    return
}


function do_compile()
{
   echo "do compile"
   cd $COMPILE_PATH
   $COMPILE_CMD $COMPILE_FILE > $SHELL_ROOT_PATH/log
   cd $SHELL_ROOT_PATH
   return
}


function output_ubi()
{
   echo "do copy $BIN_FILE"
   if [ -f "$BIN_PUT_PATH*.ubi" ]
   then
      rm $BIN_PUT_PATH*.ubi
   fi
   cp $COMPILE_PATH$BIN_FILE $BIN_PUT_PATH
}

function source_init
{
 cat /dev/null > $SHELL_ROOT_PATH/log
}

function main()
{
  echo "==================================================================================================================="
  source_init
  input $1
  source_env
  do_compile
  output_ubi
  echo "all done"
  echo "==================================================================================================================="
  exit 0
}

main $1

exit 0

