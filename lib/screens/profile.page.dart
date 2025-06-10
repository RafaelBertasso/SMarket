import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Dados Pessoais',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body:
          user == null
              ? const Center(child: Text('Usuário não encontrado.'))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 48, bottom: 24),
                      decoration: const BoxDecoration(),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Color.fromARGB(255, 211, 233, 248),
                            child: Icon(
                              Icons.person_rounded,
                              color: Color.fromRGBO(255, 255, 255, 1),
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            user!.displayName ?? 'Sem nome cadastrado',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user!.email ?? 'Sem e-mail',
                            style: GoogleFonts.inter(
                              color: Colors.grey[700],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Cards com informações
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.person_outline_rounded,
                                color: Colors.blueGrey,
                              ),
                              title: Text(
                                'Nome',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                user!.displayName ?? 'Sem nome cadastrado',
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.email_outlined,
                                color: Colors.blueGrey,
                              ),
                              title: Text(
                                'E-mail',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                user!.email ?? 'Sem e-mail',
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.blueGrey,
                              ),
                              title: Text(
                                'Conta criada em',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                user!.metadata.creationTime != null
                                    ? '${user!.metadata.creationTime!.day.toString().padLeft(2, '0')}/${user!.metadata.creationTime!.month.toString().padLeft(2, '0')}/${user!.metadata.creationTime!.year}'
                                    : 'Desconhecido',
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
