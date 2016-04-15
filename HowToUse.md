# Using the Library #

Once you have read a file into a ByteArray you just need to pass it to the SasFile object.

`     var sas:SasFile = new SasFile(bytes);   `

or if you need to

```
     var sas:SasFile = new SasFile();
     sas.loadFromBytes(bytes);
```

the SasFile will read the binary file and populate two properties for you to use:  columns and dataProvider.

now if you had a datagrid named "dg", you can do this:
```
         dg.columns = sas.columns;
         dg.dataProvider = sas.dataProvider;
```

it is not required to set the datagrid columns flash will figure them out on there own.  the columns property is an ArrayCollection or SasColumns which extend DataGridColumn.  The purpose for this is so i can extend the functionality of the datagrid column more in order to better present the SasData.


I will provide proper documentation as soon as possible.