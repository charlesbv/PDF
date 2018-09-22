for f in *.pro; do
  cat ../header $f > $f.new
  mv $f.new $f
done
