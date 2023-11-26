
for roc_file in *.roc; do
    roc check $roc_file
done

roc build cli.roc
roc build web.roc

# OPTIONAL
# for roc_file in *.roc; do
#     roc format $roc_file
# done
