set input [read [open input.txt r]]
set input [read [open example.txt r]]

foreach { first second } $input {
    puts "$first $second"
}
