#diff_log="$HOME/carmen/rbi65/xxx/diff_65_2_60.log"
diff_log="$HOME/carmen/rbi65/xxx/diff_65_2_60_2.log"

source_dir="$HOME/carmen/rbi65/xxx"
target_dir="$HOME/carmen/rbi60/sp_save"

echo "Start DIFF-Job -> Carmen6.5 vs. Carmen6.0 ..." 1> $diff_log 2>&1

#for i in `ls rbi_vr_*.vrb`
for i in `ls rbi_pa_*.v?b`
do
  echo "$i"
  echo "=====================================" 1>> $diff_log 2>&1
  echo "$i" 1>> $diff_log 2>&1
  echo "=====================================" 1>> $diff_log 2>&1
  diff -b "$source_dir"/"$i" "$target_dir"/"$i" 1>> $diff_log 2>&1
done

