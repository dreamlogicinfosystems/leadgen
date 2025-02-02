import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lead_gen/lead_gen/application/department/department_bloc.dart';
import 'package:lead_gen/lead_gen/application/lead/lead_bloc.dart';
import 'package:lead_gen/lead_gen/constants/constant.dart';
import 'package:lead_gen/lead_gen/presentation/widgets/add_lead/open_lead.dart';
import 'package:lead_gen/lead_gen/presentation/widgets/archive/filter_dialog.dart';

import '../../../../injections.dart';
import '../../core/custom_textfield.dart';

class ArchivePageBody extends StatefulWidget {
  const ArchivePageBody({super.key});

  @override
  State<ArchivePageBody> createState() => _ArchivePageBodyState();
}

class _ArchivePageBodyState extends State<ArchivePageBody> {
  final _searchController = TextEditingController();
  String filter = 'all';

  simplifyDate(String createdDate){
    final date = DateTime.parse(createdDate);

    final simpleDate = DateFormat('d/M/yy').format(date);

    return simpleDate;
  }

  @override
  void initState() {
    context.read<LeadBloc>().add(LeadEvent.getArchiveLeads("archived", "all", context));
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget loading = Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height*0.8,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Filter",style: GoogleFonts.poppins(fontSize: 14,fontWeight: FontWeight.w500),),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: (){
                      showDialog(context: context, builder: (context) => BlocProvider(
                        create: (context) => sl<LeadBloc>(),
                        child: const FilterDialog(),
                      )).then((value){
                        setState(() {
                          filter = value;
                        });
                        context.read<LeadBloc>().add(LeadEvent.getArchiveLeads(filter,"one",context));
                      });
                    },
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset('assets/images/Slider.png'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: CustomTextField(
                isBoardAddPage: true,
                controller: _searchController,
                keyBoardType: TextInputType.text,
                labelText: 'Search lead',
                onEditingComplete: (){
                  if(_searchController.text.trim()!=""){
                    context.read<LeadBloc>().add(
                      LeadEvent.getSearchedLead(_searchController.text,'archived_list',filter,context),
                    );
                  }else{
                    showErrorToastMessage("Please enter name to search");
                  }
                },
              ),
            ),
            const SizedBox(height: 15),
            BlocBuilder<LeadBloc, LeadState>(
              builder: (context, state) {
                return state.maybeWhen(
                    loadingInProgress: (){
                      return loading;
                    },
                    emptyLeadList: (error){
                      return Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height*0.7,
                          child: Center(
                            child: Text('No leads',style: GoogleFonts.poppins(fontWeight: FontWeight.w500,fontSize: 16)),
                          ),
                        ),
                      );
                    },
                    successLeadsList: (leadList){
                      return Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: leadList.length,
                            itemBuilder: (context,index){
                              return GestureDetector(
                                onTap: (){
                                  DepartmentBloc.role=="user"? () :
                                  showDialog(context: context, builder: (context) => BlocProvider(
                                    create: (context) => sl<LeadBloc>(),
                                    child: OpenLeadDialog(leadId: leadList[index].id!),
                                  ));
                                },
                                child: Card(
                                  shadowColor: Colors.black,
                                  elevation: 7,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height*0.1,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                              color: Color(0xFF8A8A8B),
                                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12),topLeft: Radius.circular(12))
                                          ),
                                          height: MediaQuery.of(context).size.height*0.1,
                                          width: 10,
                                        ),
                                        const SizedBox(width: 6),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width*0.65,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 2),
                                              Text(leadList[index].name!,style: GoogleFonts.poppins(fontSize: 14,fontWeight: FontWeight.w500),),
                                              const SizedBox(height: 2),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width*0.65,
                                                height: MediaQuery.of(context).size.height*0.061,
                                                child: Text(leadList[index].title!,style:
                                                GoogleFonts.poppins(fontSize: 11,fontWeight: FontWeight.w400,color: const Color(0xFF8A8A8B)),),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width*0.22,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top:5,right: 5),
                                                  child: Text(modifyDate(leadList[index].lastChatDate!),style: GoogleFonts.poppins(fontSize: 11,fontWeight: FontWeight.w400),),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top:35,right: 10),
                                                  child: Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Text(simplifyDate(leadList[index].createdAt!),style: GoogleFonts.poppins(fontSize: 10,fontWeight: FontWeight.w400,color: const Color(0xFFB9B9B9)),)),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      );
                    },
                    orElse: (){
                      return loading;
                    }
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
