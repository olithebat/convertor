import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:decimal/decimal.dart';

class Fluid {
  String name;
  final double factor;
  Icon icon;
  bool isCategory;
  Fluid({
    required this.name,
    required this.factor,
    required this.icon,
    this.isCategory = false,
  });
}

class Unit {
  String name;
  final double toBase;
  bool isVolume;
  Unit({
    required this.name,
    required this.toBase,
    required this.isVolume,
  });
}

class ConversionData {
  Fluid fluid;
  Unit unitFrom;
  Unit unitTo;
  double val0;
  double val1;
  ConversionData(
      {required this.fluid,
      required this.unitFrom,
      required this.unitTo,
      required this.val0,
      required this.val1});
}

class Conversion extends StatefulWidget {
  List<Fluid> fluidList = <Fluid>[
    Fluid(
        name: "Liquids",
        factor: 1.00,
        icon: Icon(Icons.water_drop),
        isCategory: true),
    Fluid(name: "Olive Oil", factor: 0.9, icon: Icon(Icons.water_drop)),
    Fluid(name: "Sunflower Oil", factor: 0.92, icon: Icon(Icons.water_drop)),
    Fluid(name: "Water", factor: 1.0, icon: Icon(Icons.water_drop)),
    Fluid(name: "Milk", factor: 1.04, icon: Icon(Icons.water_drop)),
    Fluid(
        name: "Solids",
        factor: 1.00,
        icon: Icon(Icons.water_drop),
        isCategory: true),
    Fluid(name: "Flour", factor: 0.528, icon: Icon(Icons.bakery_dining)),
    Fluid(name: "Sugar", factor: 0.85, icon: Icon(Icons.bakery_dining)),
  ];
  List<Unit> units = <Unit>[
    Unit(name: "ml", toBase: 1.0, isVolume: true),
    Unit(name: "g", toBase: 1.0, isVolume: false),
    Unit(name: "l", toBase: 1000.0, isVolume: true),
    Unit(name: "mg", toBase: 0.001, isVolume: false),
    Unit(name: "Cups", toBase: 236.6, isVolume: true),
  ];
  late Unit unitFrom;
  late Unit unitTo;
  late Fluid selectedFluid;
  Conversion({
    super.key,
  }) {
    selectedFluid = fluidList[1];
    unitFrom = units[0];
    unitTo = units[1];
  }

  @override
  State<Conversion> createState() => _ConversionState();
}

class _ConversionState extends State<Conversion> {
  var quantity = 0.0;
  var quantityG = 0.0;
  var history = <ConversionData>[];
  final listKey = GlobalKey<AnimatedListState>();

  void addEntry(ConversionData data) {
    history.insert(0, data);
    var animatedList = listKey.currentState;
    animatedList?.insertItem(0);
  }

  void updateQuantity() {
    if (widget.unitFrom.isVolume == widget.unitTo.isVolume) {
      quantityG = quantity * widget.unitFrom.toBase / widget.unitTo.toBase;
    } else {
      if (widget.unitFrom.isVolume) {
        quantityG = quantity *
            widget.unitFrom.toBase *
            widget.selectedFluid.factor /
            widget.unitTo.toBase;
      } else {
        quantityG = quantity *
            widget.unitFrom.toBase /
            widget.selectedFluid.factor /
            widget.unitTo.toBase;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Unit Converter", style: theme.textTheme.headlineMedium),
          const SizedBox(height: 15),
          Container(
              decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all()),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Form(
                      child: DropdownButtonFormField2<Fluid>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          // Add Horizontal padding using menuItemStyleData.padding so it matches
                          // the menu padding when button's width is not specified.
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // Add more decoration..
                        ),
                        hint: Text(
                          'Select Your Quantity',
                          style: theme.textTheme.bodyMedium,
                        ),
                        items: widget.fluidList
                            .map<DropdownMenuItem<Fluid>>((Fluid value) {
                          return DropdownMenuItem(
                            value: value,
                            enabled: !value.isCategory,
                            child: value.isCategory
                                ? Text(value.name)
                                : Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      value.icon,
                                      // Icon(valueItem.bank_logo),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(value.name,
                                          style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select quantity.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            widget.selectedFluid = value!;
                            updateQuantity();
                          });
                        },
                        onSaved: (value) {},
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: theme.colorScheme.surface,
                          ),
                          maxHeight: 300,
                          offset: const Offset(0, -10),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: MaterialStateProperty.all(6),
                            thumbVisibility: MaterialStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownMenu(
                          label: Text("Unit (From)"),
                          width: null,
                          initialSelection: widget.units.first,
                          onSelected: (Unit? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              widget.unitFrom = value!;
                              updateQuantity();
                            });
                          },
                          dropdownMenuEntries: widget.units
                              .map<DropdownMenuEntry<Unit>>((Unit value) {
                            return DropdownMenuEntry<Unit>(
                                value: value, label: value.name);
                          }).toList(),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            onFieldSubmitted: (text) {
                              setState(() {
                                if (text.isNotEmpty) {
                                  quantity = double.parse(text);
                                } else {
                                  quantity = 0.0;
                                }
                                updateQuantity();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '0.0',
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(widget.unitFrom.name),
                              ),
                              suffixIconConstraints:
                                  BoxConstraints(minWidth: 0, minHeight: 0),
                              constraints: BoxConstraints.tightFor(
                                width: 200,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              counterText: '',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.keyboard_double_arrow_down),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownMenu(
                          label: Text("Unit (To)"),
                          width: null,
                          initialSelection: widget.units[1],
                          onSelected: (Unit? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              widget.unitTo = value!;
                              updateQuantity();
                            });
                          },
                          dropdownMenuEntries: widget.units
                              .map<DropdownMenuEntry<Unit>>((Unit value) {
                            return DropdownMenuEntry<Unit>(
                                value: value, label: value.name);
                          }).toList(),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(widget.unitTo.name),
                              ),
                              suffixIconConstraints:
                                  BoxConstraints(minWidth: 0, minHeight: 0),
                              constraints: BoxConstraints.tightFor(
                                width: 200,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: MergeSemantics(
                              child: Text(quantityG.toStringAsFixed(2)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            addEntry(ConversionData(
                                fluid: widget.selectedFluid,
                                unitFrom: widget.unitFrom,
                                unitTo: widget.unitTo,
                                val0: quantity,
                                val1: quantityG));
                          },
                          icon: Icon(Icons.add),
                          label: Text('Add to list'),
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ))),
                        ),
                        Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add),
                          label: Text('Add to list'),
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ))),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          // Container(
          //   decoration: BoxDecoration(
          //       color: theme.colorScheme.surface,
          //       borderRadius: BorderRadius.circular(15),
          //       border: Border.all()),
          //   child: Padding(
          //     padding: const EdgeInsets.all(15.0),
          //     child: Column(children: [Text("he")]),
          //   ),
          // ),
          Expanded(
              flex: 3,
              child: ConversionList(listKey: listKey, history: history)),
        ],
      ),
    );
  }
}

class ConversionList extends StatefulWidget {
  GlobalKey<AnimatedListState> listKey;
  List<ConversionData> history;
  ConversionList({Key? key, required this.listKey, required this.history})
      : super(key: key);

  @override
  State<ConversionList> createState() => _ConversionListState();
}

class _ConversionListState extends State<ConversionList> {
  /// Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
    // This gradient goes from fully transparent to fully opaque black...
    colors: [Colors.transparent, Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.3, 0.95],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: widget.listKey,
        reverse: false,
        padding: EdgeInsets.only(bottom: 100),
        initialItemCount: widget.history.length,
        itemBuilder: (context, index, animation) {
          final convData = widget.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.favorite, size: 12),
                label: Text(
                  "${convData.fluid.name}:${convData.val0.toStringAsFixed(2)} ${convData.unitFrom.name} <=> ${convData.val1.toStringAsFixed(2)} ${convData.unitTo.name}",
                  //semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
