/* 
 * Stalker
 * Copyright (C) 2025 Andreno
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */


// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stalker/enchantment.dart';
import 'package:stalker/equipment_type.dart';
import 'package:stalker/equipment.dart';
import 'package:stalker/records_manager.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  @override
  void initState() {
    super.initState();
  }

  Row generateCheckbox(
      String name, bool value, void Function(bool?) onChanged) {
    return Row(
      children: [
        Text(name),
        const SizedBox(
          width: 50,
        ),
        Checkbox(value: value, onChanged: onChanged)
      ],
    );
  }

  void _becomeTitan(BuildContext context) {
    for (var e in [
      (EquipmentType.weapon, "WEAPON_TITAN_GIANT_SWORD"),
      (EquipmentType.ranged, "RANGED_TITANS_HARPOON"),
      (EquipmentType.magic, "MAGIC_MIND_THROW"),
      (EquipmentType.armor, "BODY_TITAN"),
      (EquipmentType.helm, "HEAD_TITAN")
    ]) {
      var equipment = RecordsManager.activeRecord!.equipment[e.$1]
          ?.where((i) => i.id == e.$2)
          .firstOrNull;
      if (equipment == null) {
        equipment = Equipment(e.$1, e.$2, 52, 4);
        RecordsManager.activeRecord!.equipment[e.$1]!.add(equipment);
      }
      RecordsManager.activeRecord!.setEquipped(equipment);
    }

    RecordsManager.saveRecord(RecordsManager.activeRecord!)
        .then((_) => Fluttertoast.showToast(msg: "Became Titan!"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1,
      padding: EdgeInsets.zero,
      shrinkWrap: false,
      children: [
        (
          "Weapon",
          "assets/images/katana.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const EquipmentTypePage(EquipmentType.weapon)))
              }
        ),
        (
          "Ranged",
          "assets/images/shuriken.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const EquipmentTypePage(EquipmentType.ranged)))
              }
        ),
        (
          "Magic",
          "assets/images/amulet.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const EquipmentTypePage(EquipmentType.magic)))
              }
        ),
        (
          "Armor",
          "assets/images/armor.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const EquipmentTypePage(EquipmentType.armor)))
              }
        ),
        (
          "Helm",
          "assets/images/helm.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const EquipmentTypePage(EquipmentType.helm)))
              }
        ),
        (
          "Become Titan",
          "assets/images/robot-assistant.png",
          () => _becomeTitan(context)
        ),
      ].map((entry) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceTint
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)),
              child: TextButton(
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: const ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)))),
                onPressed: () => entry.$3(),
                child: Image.asset(entry.$2, width: 64, height: 64),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.$1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        );
      }).toList(),
    ));
  }
}

class EquipmentTypePage extends StatefulWidget {
  final EquipmentType type;

  const EquipmentTypePage(this.type, {super.key});
  @override
  State<EquipmentTypePage> createState() => _EquipmentTypePageState();

  static void save() {
    RecordsManager.saveRecordWithToast(RecordsManager.activeRecord!);
  }
}

class _EquipmentTypePageState extends State<EquipmentTypePage> {
  @override
  @override
  Widget build(BuildContext context) {
    final equipment = RecordsManager.activeRecord!.equipment[widget.type]!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: Scrollbar(
          interactive: true,
          thickness: 10,
          child: ListView(
            padding: const EdgeInsets.all(4),
            children: [
              ...equipment.asMap().entries.map((entry) {
                final item = entry.value;
                final isEquipped =
                    RecordsManager.activeRecord!.isEquipped(item);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: isEquipped
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            width: isEquipped ? 2 : 1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16))),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                equipment.remove(item);
                              });
                            },
                          ),
                          Expanded(child: Text(item.name))
                        ],
                      ),
                      subtitle: isEquipped
                          ? const Padding(
                              padding: EdgeInsets.only(left: 48.0),
                              child: Text(
                                "Equipped",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            title: const Text("Enchantments"),
                            children: [
                              ...item.enchantments.map((applied) => Padding(
                                    padding: const EdgeInsets.only(left: 24.0),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text(applied.enchantment.name)),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                item.enchantments.remove(applied);
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                        ],
                                      ),
                                      subtitle: applied.aspect == null
                                          ? null
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 12.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                      "Aspect: ${applied.aspect}"),
                                                  Expanded(
                                                    child: Slider(
                                                      value: applied.aspect!
                                                          .toDouble(),
                                                      onChanged: (v) {
                                                        setState(() {
                                                          applied.aspect =
                                                              v.toInt();
                                                        });
                                                      },
                                                      min: 0,
                                                      max: AppliedEnchantment
                                                          .maxAspect
                                                          .toDouble(),
                                                      divisions:
                                                          AppliedEnchantment
                                                              .maxAspect,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: ListTile(
                                  title: OutlinedButton(
                                    onPressed: () {
                                      showAddEnchantmentDialog(widget.type)
                                          .future
                                          .then((selected) {
                                        if (selected != null) {
                                          setState(() {
                                            item.enchantments.add(
                                              AppliedEnchantment(
                                                selected,
                                                selected.tier ==
                                                        EnchantmentTier.mythical
                                                    ? null
                                                    : 0,
                                              ),
                                            );
                                          });
                                          Navigator.of(context).pop();
                                        }
                                      });
                                    },
                                    child: const Text("Add..."),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text("Level: ${item.level}"),
                                Slider(
                                  value: item.level.toDouble(),
                                  onChanged: (n) {
                                    setState(() => item.level = n.toInt());
                                  },
                                  min: 1,
                                  max: 52,
                                  divisions: 51,
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                    "Upgrade level: ${item.upgrade == 0 ? "Not upgraded" : item.upgrade}"),
                                Expanded(
                                  child: Slider(
                                    value: item.upgrade.toDouble(),
                                    onChanged: (n) {
                                      setState(() => item.upgrade = n.toInt());
                                    },
                                    min: 0,
                                    max: 4,
                                    divisions: 4,
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                          ),
                        ),
                        isEquipped
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16.0, right: 16, left: 16),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          RecordsManager.activeRecord!
                                              .setEquipped(item);
                                        });
                                      },
                                      child: const Text("Equip")),
                                ),
                              )
                      ],
                    ),
                  ),
                );
              }),
              ListTile(
                title: FilledButton(
                  onPressed: () {
                    showNewEquipmentDialog().future.then((equipmentId) {
                      if (equipmentId != null) {
                        setState(() {
                          RecordsManager.activeRecord!.equipment[widget.type]!
                              .add(Equipment(widget.type, equipmentId, 1, 0));
                          Navigator.of(context).pop();
                        });
                      }
                    });
                  },
                  child: const Text("Add..."),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: EquipmentTypePage.save,
        child: Icon(Icons.save),
      ),
    );
  }

  Completer<Enchantment?> showAddEnchantmentDialog(EquipmentType type) {
    Completer<Enchantment?> selected = Completer();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Add an enchantment")),
        content: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: ListView(
            children: [
              const Center(
                child: Text(
                  "Simple Enchantments",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ...enchantments
                  .where((e) =>
                      e.idFor(type) != null && e.tier == EnchantmentTier.simple)
                  .map((e) => FilledButton(
                      onPressed: () {
                        selected.complete(e);
                      },
                      child: Text(e.name))),
              const Center(
                child: Text(
                  "Medium Enchantments",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ...enchantments
                  .where((e) =>
                      e.idFor(type) != null && e.tier == EnchantmentTier.medium)
                  .map((e) => FilledButton(
                      onPressed: () {
                        selected.complete(e);
                      },
                      child: Text(e.name))),
              const Center(
                child: Text(
                  "Mythical Enchantments",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ...enchantments
                  .where((e) =>
                      e.idFor(type) != null &&
                      e.tier == EnchantmentTier.mythical)
                  .map((e) => FilledButton(
                      onPressed: () {
                        selected.complete(e);
                      },
                      child: Text(e.name))),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (!selected.isCompleted) {
        selected.complete(null);
      }
    });

    return selected;
  }

  Completer<String?> showNewEquipmentDialog() {
    Completer<String?> equipmentId = Completer();
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a new item"),
        content: TextField(
          autocorrect: false,
          autofocus: true,
          maxLines: 1,
          decoration: const InputDecoration(
            hintText: "Enter item ID...",
            errorText: null,
          ),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                equipmentId.complete(controller.text);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    ).then((_) {
      if (!equipmentId.isCompleted) {
        equipmentId.complete(null);
        controller.dispose();
      }
    });

    return equipmentId;
  }
}
