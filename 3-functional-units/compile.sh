#!/bin/bash

case $1 in
    i)
        iverilog -Wall -g 2012 -s multiplier_iterative_tb -o ./test_iter multiplier_iterative_v$2.v multiplier_iterative_tb.v && 
    ./test_iter 
    ;;
    p)
        if [[ $2 -eq 5 ]]
        then 
        iverilog -Wall -g 2012 -s multiplier_parallel_tb -o ./test_pipe multiplier_pipelined_v$2.v multiplier_parallel_tb.v && 
    ./test_pipe
        else
        iverilog -Wall -g 2012 -s multiplier_pipelined_tb -o ./test_pipe multiplier_pipelined_v$2.v multiplier_pipelined_tb.v && 
    ./test_pipe 
        fi
    ;;
    r)
        echo "Which type: ramdom (r) or simple (s)"
        read t
        if [[ $t -eq "r" ]] || [[ $t -ge "R" ]] 
        then 
            iverilog -Wall -g 2012 -s register_file_tb -o ./test_rf_random register_file_v$2.v register_file_tb_random.v && 
        ./test_rf_random 
        elif [[ $t -eq "s" ]] || [[ $t -ge "S" ]]
        then 
            iverilog -Wall -g 2012 -s register_file_tb_simple -o ./test_rf_simple register_file_v$2.v register_file_tb_simple.v && 
        ./test_rf_simple 
        fi
    ;;
    a)
        iverilog -Wall -g 2012 -s multiplier_iterative_tb -o ./test_iter multiplier_iterative_v$2.v multiplier_iterative_tb.v && 
    ./test_iter 

        iverilog -Wall -g 2012 -s multiplier_pipelined_tb -o ./test_pipe multiplier_pipelined_v$2.v multiplier_pipelined_tb.v && 
    ./test_pipe 

        echo "Which type: ramdom (r) or simple (s)"
        read t
        if [[ $t -eq "r" ]] 
        then 
            iverilog -Wall -g 2012 -s register_file_tb -o ./test_rf_random register_file_v$2.v register_file_tb_random.v && 
        ./test_rf_random 
        elif [[ $t -eq 's' ]] #|| [[ $t -eq 'S']] 
        then 
            iverilog -Wall -g 2012 -s register_file_tb_simple -o ./test_rf_simple register_file_v$2.v register_file_tb_simple.v && 
        ./test_rf_simple 
        fi
    ;;
esac