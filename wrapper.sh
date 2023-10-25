#!/usr/bin/ksh

root_path=""
tpt="tpt_scripts/"
sqlldr="sql_loader/" 
ctl="sql_loader/control_files/"

gen_tptexp_script="gen_tptexp_script.sh"
run_tpt_scripts="run_tpt_scripts.sh"
gen_sqlloader_ctl="gen_sqlloader_ctl.sh"
run_sqlldr_script="run_sqlldr_script.sh"


# run 1
# generate tpt scripts 
cd "$root_path" || exit 1
sh "$gen_tptexp_script"
if [ $? -ne 0 ]; then 
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"    
    echo "Error executing $gen_tptexp_script"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
else
    echo "$gen_tptexp_script executed successfully"
fi

# run 2
# execute tpt scripts
cd "$tpt" || exit 1
sh "$run_tpt_scripts"
if [ $? -ne 0 ]; then 
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Error executing $run_tpt_scripts"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
else
    echo "$run_tpt_scripts executed successfully"
fi

# run 3
# generate sql loader scripts
cd "$sqlldr" || exit 1
sh "$gen_sqlloader_ctl"
if [ $? -ne 0 ]; then 
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Error executing $gen_sqlloader_ctl"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
else
    echo "$gen_sqlloader_ctl executed successfully"
fi

# run 4
# execute sql loader scripts
cd "$ctl" || exit 1
sh "$run_sqlldr_script"
if [ $? -ne 0 ]; then 
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Error executing $run_sqlldr_script"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
else
    echo "$run_sqlldr_script executed successfully"
fi
