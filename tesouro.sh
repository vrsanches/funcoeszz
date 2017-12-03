#!/bin/bash

source  /usr/bin/funcoeszz      #   inclui o ambiente ZZ
ZZPATH=$PWD/tesouro.sh

# ----------------------------------------------------------------------------
# http://www.tesouro.fazenda.gov.br/tesouro-direto-precos-e-taxas-dos-titulos 
# Exibe os títulos disponíveis do Tesouro Direto para compra e venda. 
#
# Opções: 
#           -c, --comprar    Mostra os títulos disponíveis para investir
#           -v, --vender     Mostra os títulos disponíveis para resgatar
#           -i, --indexado   Mostra os títulos indexados (IPCA, IGP-M)
#           -p, --prefixado  Mostra os títulos prefixados
#           -s, --selic      Mostra os títulos indexados à SELIC (pósfixados)
#
# Se não houver opções, mostra a lista completa de títulos para investir
# e resgatar.
#
# Formatação dos campos da tabela de títulos para investir:
#  Título | Vencimento | Rendimento (%a.a.) | Valor Mínimo | Preço Unitário
# Formatação dos campos da tabela de títulos para resgatar:
#  Título | Vencimento | Rendimento (%a.a.) | Preço Unitário
#
# Uso: zztesouro [--opção] [--tipo]
# Ex:   zztesouro -c -s
#       zztesouro --comprar --selic
#       zztesouro -p
#
# Autor: Vinicius R Sanches, @vrsanches
# Versão: 1.0
# Licença: GPL
# Requisitos: xmlstarlet wget 
# ----------------------------------------------------------------------------

zztesouro()
{
    zzzz -h tesouro "$1" && return

    local url="http://www.tesouro.fazenda.gov.br/tesouro-direto-precos-e-tax"\
"as-dos-titulos"
    local tagscomprar="/html/body/div/div/div/div/div/div/div/div/div/div/ta"\
"ble/tbody/tr/td[@class='listing0' or @class='listing' or @class='listing ']"
    local tagsvender="/html/body/div/div/div/div/div/div/div/div/div/div/div"\
"/table/tbody/tr/td[@class='listing0' or @class='listing' or @class='listing"\
"']"

    local op=0      
    #   0 para todos, 1 compra, 2 venda
    local busca=".*"
    #   se nada for passado, mostra tudo


    while test -n "$1"
    do    
        case "$1" in
            -c | --comprar  )   op=1                ;;
            -v | --vender   )   op=2                ;;
            -i | --indexado )   busca="+"           ;;
            -p | --prefixado)   busca="Prefixado"   ;;
            -s | --selic    )   busca="Selic"       ;;   
            *)
            # opcao invalida
                echo "Opção inválida. Digite $0 -h ou --help para ajuda."
                exit 0
            ;;
        esac
        shift
    done

    local comprar=$(wget -q -O- $url |\
                        xmlstarlet format --recover --html 2>/dev/null |\
                        xmlstarlet select --html --template --value-of "/htm"\
"l/body/div/div/div/div/div/div/div/div/div/div/table/tbody/tr/td[@class='li"\
"sting0' or @class='listing' or @class='listing ']" |\
                        paste -d ";" - - - - - |\
                        column -s ";" -t |\
                        grep -i -e "$busca")
    local vender=$(wget -q -O- $url |\
                        xmlstarlet format --recover --html 2>/dev/null |\
                        xmlstarlet select --html --template --value-of "/htm"\
"l/body/div/div/div/div/div/div/div/div/div/div/div/table/tbody/tr/td[@class"\
"='listing0' or @class='listing' or @class='listing ']" |\
                        paste -d ";" - - - - |\
                        column -s ";" -t |\
                        grep -i -e "$busca")

    if test "$op" = 0
    then
        #   executa comprar e vender
        echo "Comprar"
        echo "$comprar"
        echo "Vender"
        echo "$vender"
    fi
    if test "$op" = 1
    then
        #   executa comprar
        echo "$comprar"
    fi
    if test "$op" = 2
    then
        #   executa vender
        echo "$vender"
    fi
}
