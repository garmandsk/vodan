import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VodanQuantityButton extends StatefulWidget {
  const VodanQuantityButton({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final ValueChanged<int> onChanged;

  @override
  State<VodanQuantityButton> createState() => _VodanQuantityButtonState();
}

class _VodanQuantityButtonState extends State<VodanQuantityButton> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  void _submitValue() {
    final newValue = int.tryParse(_controller.text) ?? 0;
    if (newValue > 0) {
      widget.onChanged(newValue);
    } else {
      _controller.text = widget.quantity.toString();
    }
  }

  @override void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.quantity.toString());
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _submitValue();
      }
    });
  }

  @override 
  void didUpdateWidget(covariant VodanQuantityButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.quantity != widget.quantity) {
      if (_controller.text != widget.quantity.toString()) {
        _controller.text = widget.quantity.toString();
      }
    }
  }

  @override  
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Jika kuantitas 0, tampilkan tombol [+] bulat
    if (widget.quantity <= 0) {
      return InkWell(
        onTap: widget.onAdd,
        borderRadius: BorderRadius.circular(20),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: const Icon(Icons.add, size: 20),
        ),
      );
    }

    // Jika kuantitas > 0, tampilkan pill [- 1 +]
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove, 
              size: 16, 
              color: theme.colorScheme.onPrimaryContainer
            ),
            onPressed: () {
              _focusNode.unfocus();
              widget.onRemove();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32),
          ),
          SizedBox(
            width: 36, 
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: theme.colorScheme.onPrimary,
              cursorWidth: 2.0,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: theme.colorScheme.onPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false
              ),
              onSubmitted: (_) => _focusNode.unfocus(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 16, color: theme.colorScheme.onPrimaryContainer),
            onPressed: () {
              _focusNode.unfocus();
              widget.onAdd();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32),
          ),
        ],
      ),
    );
  }
}