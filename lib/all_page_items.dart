import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import 'classes.dart';

class RestaurantItem extends StatelessWidget {
  final Datum meal;

  const RestaurantItem({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,// Stack ignored shape so we use clipBehavior to show rounded shape
      elevation: 2,  // it used to add a slight drop shadow behind card and give this card some elevation, some 3D effect
      child: InkWell(
      //  onTap: (){ onSelectMeal(context ,meal); },
        child: Stack(
          children: [
            Hero(
              tag: meal.id,
              child: FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: NetworkImage(meal.primaryImage),
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            Positioned(
              bottom: 43,
              left: 250,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(0),
                  topLeft: Radius.circular(0),
                ),
                child: Container(
                  color: Colors.green,
                  child:  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(meal.rating.toString(), maxLines: 2,textAlign: TextAlign.center,softWrap: true,
                                  overflow: TextOverflow.ellipsis,  // very long text = ...
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        const Icon(Icons.star,color: Colors.white,),
                      ],
                    ),
                  ),
                          //  const SizedBox(width: 40,),

                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 44),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(meal.name, maxLines: 2,textAlign: TextAlign.center,softWrap: true,
                          overflow: TextOverflow.ellipsis,  // very long text = ...
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      //  const SizedBox(width: 40,),
                        Text(meal.discount.toString()+"%FLAT OFF", maxLines: 2,textAlign: TextAlign.end,softWrap: true,
                          overflow: TextOverflow.ellipsis,  // very long text = ...
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
