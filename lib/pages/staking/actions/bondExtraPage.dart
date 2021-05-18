import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sp_polkadot/sp_polkadot.dart';
import 'package:sp_polkadot/utils/i18n/index.dart';
import 'package:settpay_sdk/storage/keyring.dart';
import 'package:settpay_sdk/utils/i18n.dart';
import 'package:settpay_ui/components/addressFormItem.dart';
import 'package:settpay_ui/components/txButton.dart';
import 'package:settpay_ui/utils/index.dart';
import 'package:settpay_ui/utils/format.dart';

class BondExtraPage extends StatefulWidget {
  BondExtraPage(this.plugin, this.keyring);
  static final String route = '/staking/bondExtra';
  final PluginPolkadot plugin;
  final Keyring keyring;
  @override
  _BondExtraPageState createState() => _BondExtraPageState();
}

class _BondExtraPageState extends State<BondExtraPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_kusama, 'common');
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final symbol = widget.plugin.networkState.tokenSymbol[0];
    final decimals = widget.plugin.networkState.tokenDecimals[0];

    double available = 0;
    if (widget.plugin.balances.native != null) {
      available = Fmt.balanceDouble(
          widget.plugin.balances.native.availableBalance.toString(), decimals);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dicStaking['action.bondExtra']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      AddressFormItem(
                        widget.keyring.current,
                        label: dicStaking['stash'],
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: dic['amount'],
                          labelText:
                              '${dic['amount']} (${dicStaking['available']}: ${Fmt.priceFloor(
                            available,
                            lengthMax: 4,
                          )} $symbol)',
                        ),
                        inputFormatters: [UI.decimalInputFormatter(decimals)],
                        controller: _amountCtrl,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v.isEmpty) {
                            return dic['amount.error'];
                          }
                          if (double.parse(v.trim()) >= available) {
                            return dic['amount.low'];
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TxButton(
                  getTxParams: () async {
                    if (_formKey.currentState.validate()) {
                      final inputAmount = _amountCtrl.text.trim();
                      return TxConfirmParams(
                        txTitle: dicStaking['action.bondExtra'],
                        module: 'staking',
                        call: 'bondExtra',
                        txDisplay: {"amount": '$inputAmount $symbol'},
                        params: [
                          // "amount"
                          Fmt.tokenInt(inputAmount, decimals).toString(),
                        ],
                      );
                    }
                    return null;
                  },
                  onFinish: (Map res) {
                    if (res != null) {
                      Navigator.of(context).pop(res);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
