import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/data/repositories/branch_repository.dart';

class StaffShopInfoPanel extends StatefulWidget {
  const StaffShopInfoPanel({super.key});

  @override
  State<StaffShopInfoPanel> createState() => _StaffShopInfoPanelState();
}

class _StaffShopInfoPanelState extends State<StaffShopInfoPanel> {
  bool _isExpanded = false;
  final _branchRepo = BranchRepository();

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(BootstrapIcons.shop, color: gold, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Shop Info & Support',
                        style: TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? BootstrapIcons.chevron_up : BootstrapIcons.chevron_down,
                    color: gold,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.white12, height: 1),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _branchRepo.getAllBranches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: gold)),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No shop details available.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  );
                }

                final branches = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  itemCount: branches.length,
                  separatorBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: gold, height: 5),
                  ),
                  itemBuilder: (context, index) {
                    final b = branches[index];
                    final name = b['branchName'] ?? '';
                    final address = b['address'] ?? '';
                    final phone = b['phone'] ?? '';
                    final operatingHours = b['operatingHours'] as Map<dynamic, dynamic>?;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: const TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(BootstrapIcons.geo_alt_fill, color: gold.withValues(alpha: 0.9), size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                address,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(BootstrapIcons.telephone_fill, color: gold.withValues(alpha: 0.9), size: 16),
                            const SizedBox(width: 10),
                            Text(
                              phone,
                              style: const TextStyle(
                                color: gold,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Operating Hours:',
                          style: TextStyle(
                            color: gold,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...() {
                          if (operatingHours == null) return [const SizedBox()];
                          
                          final mon = operatingHours['monday']?.toString().trim() ?? 'Closed';
                          final tue = operatingHours['tuesday']?.toString().trim() ?? 'Closed';
                          final wed = operatingHours['wednesday']?.toString().trim() ?? 'Closed';
                          final thu = operatingHours['thursday']?.toString().trim() ?? 'Closed';
                          final fri = operatingHours['friday']?.toString().trim() ?? 'Closed';
                          final sat = operatingHours['saturday']?.toString().trim() ?? 'Closed';
                          final sun = operatingHours['sunday']?.toString().trim() ?? 'Closed';

                          bool isMonSatSame = mon.isNotEmpty && mon == tue && mon == wed && mon == thu && mon == fri && mon == sat;

                          Widget buildRow(String label, String value) {
                            final isClosed = value.isEmpty || value.toLowerCase() == 'closed';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                                  Text(
                                    isClosed ? 'Closed' : value,
                                    style: TextStyle(
                                      color: isClosed ? Colors.redAccent : Colors.white,
                                      fontSize: 13,
                                      fontWeight: isClosed ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (isMonSatSame) {
                            return [
                              buildRow('Monday - Saturday', mon),
                              buildRow('Sunday', sun),
                            ];
                          } else {
                            return [
                              buildRow('Monday', mon),
                              buildRow('Tuesday', tue),
                              buildRow('Wednesday', wed),
                              buildRow('Thursday', thu),
                              buildRow('Friday', fri),
                              buildRow('Saturday', sat),
                              buildRow('Sunday', sun),
                            ];
                          }
                        }(),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
