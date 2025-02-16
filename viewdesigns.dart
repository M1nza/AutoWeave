import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ViewDesignsPage extends StatefulWidget {
  const ViewDesignsPage({Key? key}) : super(key: key);

  @override
  _ViewDesignsPageState createState() => _ViewDesignsPageState();
}

class _ViewDesignsPageState extends State<ViewDesignsPage> {
  List<dynamic> designs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDesigns();
  }

  Future<void> fetchDesigns() async {
    String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
    String loginId = (await SharedPreferences.getInstance()).getString('lid') ?? '';
    final response = await http.get(Uri.parse(url+'user_viewdesigns?lid=$loginId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ok') {
        setState(() {
          designs = data['data'];
          for (int i = 0; i < designs.length; i++) {
            designs[i]['Image'] = url + designs[i]['Image'];
          }
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load designs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF400A0C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'View Designs',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF500E10),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: designs.length,
            itemBuilder: (context, index) {
              final design = designs[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DesignDetailsPage(design: design),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: const Color(0xFF000000),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              design['Description'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFE6E8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                design['Image'],
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF400A0C),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date: ${design['Date'].toString()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}



class DesignDetailsPage extends StatefulWidget {
  final dynamic design;

  const DesignDetailsPage({Key? key, required this.design}) : super(key: key);

  @override
  _DesignDetailsPageState createState() => _DesignDetailsPageState();
}

class _DesignDetailsPageState extends State<DesignDetailsPage> {
  List<dynamic> materials = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMaterials(widget.design['id'].toString());
  }


  // Show SnackBar message
  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> fetchMaterials(String designId) async {
    String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
    var response = await http.post(
      Uri.parse(url + "view_material"),
      body: {'design_id': designId},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ok') {
        setState(() {
          materials = data['data'];
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to fetch materials');
    }
  }

  Future<void> bookingfn(String mid,String did) async {
    // setState(() {
    //   isLoading = true;
    // });
    print("okkkkkkkkkkkkkkk");
    try {
      String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
      String lid = (await SharedPreferences.getInstance()).getString('lid') ?? '';
      final response = await http.post(
          Uri.parse(url + "user_booking"),body: {
        "lid":lid,"did":did,"mid":mid
      }
        // No design_name sent in the body now
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['task'] == 'valid') {
          setState(()

          {
            showSnackBar('Booked Successfully !', Colors.green);
          });
        } else {
          showSnackBar('Failed to fetch data!', Colors.red);
        }
      } else {
        showSnackBar('Server error. Please try again later!', Colors.red);
      }
    } catch (error) {
      showSnackBar('Error: $error', Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Design Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF400A0C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.design['Image'],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF400A0C),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.design['Description'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFE6E8),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Date: ${widget.design['Date']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF500E10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: Colors.grey),
                ),
                onPressed: () async {
                  // bookingfn(budget['id'].toString(),budget['eid'].toString());
                  bookingfn(widget.design['id'].toString(), widget.design['eid'].toString());

                },
                child: const Text(
                  'Book Now!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF400A0C),
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final material = materials[index];
                    return Card(
                      color: const Color(0xFF1A1A1A),
                      child: ListTile(
                        title: Text(
                          material['MATERIALS'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Amount: ${material['amount']}\nDetails: ${material['details']}\nDate: ${material['date']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
