import 'package:flutter/material.dart';

enum JobType { restaurant, farmProduce, clothing, supermarket, parcels }
enum ParcelSize { small, large }
enum VehicleType { bikeOrSmallVehicle, van, truck }

class RiderOrdersPage extends StatefulWidget {
  static const routeName = '/rider-orders';
  const RiderOrdersPage({super.key});

  @override
  State<RiderOrdersPage> createState() => _RiderOrdersPageState();
}

class _RiderOrdersPageState extends State<RiderOrdersPage> {
  // ✅ Mock jobs list (until Firestore is added)
  final List<_RiderJob> _jobs = [
    _RiderJob(
      id: "JOB-001",
      type: JobType.restaurant,
      title: "Restaurant Delivery",
      pickup: "Mama Put (Kubwa)",
      dropoff: "Phase 2, behind the church",
      amount: 1200,
      parcelSize: ParcelSize.small,
      vehicle: VehicleType.bikeOrSmallVehicle,
      status: _JobStatus.newRequest,
    ),
    _RiderJob(
      id: "JOB-002",
      type: JobType.supermarket,
      title: "Supermarket Order",
      pickup: "RuralGo Mart (Zuba)",
      dropoff: "After village square, opposite school",
      amount: 1500,
      parcelSize: ParcelSize.small,
      vehicle: VehicleType.bikeOrSmallVehicle,
      status: _JobStatus.newRequest,
    ),
    _RiderJob(
      id: "JOB-003",
      type: JobType.clothing,
      title: "Clothing Delivery",
      pickup: "StyleHub (Wuse)",
      dropoff: "Near borehole, behind the mosque",
      amount: 1700,
      parcelSize: ParcelSize.small,
      vehicle: VehicleType.bikeOrSmallVehicle,
      status: _JobStatus.newRequest,
    ),
    _RiderJob(
      id: "JOB-004",
      type: JobType.parcels,
      title: "Parcels & Relocation Assistant",
      pickup: "Lugbe (Block 7)",
      dropoff: "Gwagwalada (Market road)",
      amount: 5500,
      parcelSize: ParcelSize.large,
      vehicle: VehicleType.van,
      needsLoadingHelp: true,
      status: _JobStatus.newRequest,
    ),
    _RiderJob(
      id: "JOB-005",
      type: JobType.farmProduce,
      title: "Farm Produce Delivery",
      pickup: "Keffi Farm Gate",
      dropoff: "Mararaba, after the bridge",
      amount: 2000,
      parcelSize: ParcelSize.small,
      vehicle: VehicleType.bikeOrSmallVehicle,
      status: _JobStatus.newRequest,
    ),
  ];

  JobType? _filter; // null = show all

  List<_RiderJob> get _filteredJobs {
    if (_filter == null) return _jobs;
    return _jobs.where((j) => j.type == _filter).toList();
  }

  void _acceptJob(String id) {
    setState(() {
      final idx = _jobs.indexWhere((j) => j.id == id);
      if (idx != -1) _jobs[idx] = _jobs[idx].copyWith(status: _JobStatus.active);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Accepted ✅ Job moved to Active")),
    );
  }

  void _completeJob(String id) {
    setState(() {
      final idx = _jobs.indexWhere((j) => j.id == id);
      if (idx != -1) _jobs[idx] = _jobs[idx].copyWith(status: _JobStatus.completed);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Completed ✅ Earnings added (mock)")),
    );
  }

  IconData _typeIcon(JobType t) {
    switch (t) {
      case JobType.restaurant:
        return Icons.restaurant;
      case JobType.farmProduce:
        return Icons.agriculture;
      case JobType.clothing:
        return Icons.checkroom;
      case JobType.supermarket:
        return Icons.shopping_basket;
      case JobType.parcels:
        return Icons.local_shipping;
    }
  }

  String _typeLabel(JobType t) {
    switch (t) {
      case JobType.restaurant:
        return "Restaurant";
      case JobType.farmProduce:
        return "Farm Produce";
      case JobType.clothing:
        return "Clothing";
      case JobType.supermarket:
        return "Supermarket";
      case JobType.parcels:
        return "Parcels/Relocation";
    }
  }

  String _vehicleLabel(VehicleType v) {
    switch (v) {
      case VehicleType.bikeOrSmallVehicle:
        return "Bike/Small Vehicle";
      case VehicleType.van:
        return "Van";
      case VehicleType.truck:
        return "Truck";
    }
  }

  String _sizeLabel(ParcelSize s) => s == ParcelSize.small ? "Small item" : "Large item";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rider Orders"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text("All"),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              ...JobType.values.map(
                (t) => ChoiceChip(
                  label: Text(_typeLabel(t)),
                  selected: _filter == t,
                  onSelected: (_) => setState(() => _filter = t),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (_filteredJobs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Text("No jobs yet."),
              ),
            ),

          ..._filteredJobs.map((job) {
            final isActive = job.status == _JobStatus.active;
            final isNew = job.status == _JobStatus.newRequest;
            final isDone = job.status == _JobStatus.completed;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_typeIcon(job.type), color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green.withOpacity(0.15)
                                : isActive
                                    ? Colors.orange.withOpacity(0.18)
                                    : Colors.blue.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            isDone ? "Completed" : isActive ? "Active" : "New",
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text("Pickup: ${job.pickup}", style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text("Drop-off: ${job.dropoff}", style: const TextStyle(fontWeight: FontWeight.w700)),

                    const SizedBox(height: 10),

                    // ✅ Size + Vehicle + Loading Help
                    Row(
                      children: [
                        _smallTag(_sizeLabel(job.parcelSize)),
                        const SizedBox(width: 8),
                        _smallTag(_vehicleLabel(job.vehicle)),
                        if (job.needsLoadingHelp) ...[
                          const SizedBox(width: 8),
                          _smallTag("Loading help"),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Pay: ₦${job.amount.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),

                    const SizedBox(height: 10),

                    // ✅ Actions
                    if (isNew)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _acceptJob(job.id),
                          child: const Text("Accept Job"),
                        ),
                      ),

                    if (isActive)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _completeJob(job.id),
                          child: const Text("Mark Completed"),
                        ),
                      ),

                    if (isDone)
                      const Text(
                        "✅ Job completed. Earnings recorded (mock).",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

enum _JobStatus { newRequest, active, completed }

class _RiderJob {
  final String id;
  final JobType type;
  final String title;
  final String pickup;
  final String dropoff;
  final double amount;

  final ParcelSize parcelSize;
  final VehicleType vehicle;
  final bool needsLoadingHelp;

  final _JobStatus status;

  _RiderJob({
    required this.id,
    required this.type,
    required this.title,
    required this.pickup,
    required this.dropoff,
    required this.amount,
    required this.parcelSize,
    required this.vehicle,
    this.needsLoadingHelp = false,
    required this.status,
  });

  _RiderJob copyWith({_JobStatus? status}) {
    return _RiderJob(
      id: id,
      type: type,
      title: title,
      pickup: pickup,
      dropoff: dropoff,
      amount: amount,
      parcelSize: parcelSize,
      vehicle: vehicle,
      needsLoadingHelp: needsLoadingHelp,
      status: status ?? this.status,
    );
  }
}