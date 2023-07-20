import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:junior_test/model/RootResponse.dart';
import 'package:junior_test/model/actions/PromoItem.dart';
import 'package:junior_test/resources/api/repository.dart';
import 'package:junior_test/tools/CustomNetworkImageLoader.dart';
import 'package:junior_test/tools/MyDimens.dart';
import 'package:junior_test/tools/Strings.dart';
import 'package:junior_test/tools/Tools.dart';
import 'package:junior_test/ui/actions/item/ActionsItemArguments.dart';
import 'package:junior_test/ui/actions/item/ActionsItemWidget.dart';

class ActionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ActionsItemWidget.TAG: (context) => ActionsItemWidget(),
      },
      home: Scaffold(
        backgroundColor: Colors.grey[700],
        body: CustomScrollViewWidget(),
      ),
    );
  }
}

class CustomScrollViewWidget extends StatelessWidget {
  const CustomScrollViewWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: MediaQuery.of(context).size.height / 3,
          // collapsedHeight: (MediaQuery.of(context).size.height / 6),
          backgroundColor: Colors.grey[900],
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double opacityVar;
              if (constraints.biggest.height <=
                  MediaQuery.of(context).size.height / 6) {
                opacityVar = 1.0;
              } else {
                opacityVar = 0.0;
              }
              return FlexibleSpaceBar(
                centerTitle: true,
                title: AnimatedOpacity(
                  duration: Duration(milliseconds: 100),
                  opacity: opacityVar,
                  child: Text(
                    Strings.actions,
                    style: TextStyle(
                      fontSize: MyDimens.titleNormal,
                    ),
                  ),
                ),
                background: Image.network(
                  "https://live4fun.ru/data/old_pictures/img_13200033_483_7.jpg",
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        SliverStaggeredGridWidget(),
      ],
    );
  }
}

class SliverStaggeredGridWidget extends StatelessWidget {
  const SliverStaggeredGridWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Repository repository = new Repository();
    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: 4,
      itemCount: 10,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemBuilder: (BuildContext context, int index) =>
          CustomFutureBuilderWidget(promoIndex: index, repository: repository),
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
    );
  }
}

class CustomFutureBuilderWidget extends StatelessWidget {
  const CustomFutureBuilderWidget({Key key, this.promoIndex, this.repository})
      : super(key: key);

  final int promoIndex;
  final Repository repository;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: FutureBuilder<RootResponse>(
        future: repository.fetchPromos(promoIndex, 1),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.serverResponse.body.promo.list.isNotEmpty)
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  ActionsItemWidget.TAG,
                  arguments: ActionsItemArguments(snapshot.data.serverResponse.body.promo.list.first.id),
                ),
                child: PromoItemWidget(
                  promoItem: snapshot.data.serverResponse.body.promo.list.first,
                  promoIndex: promoIndex,
                ),
              );
            else {
              return Container();
            }
          } else {
            return Container(
              height: ((MediaQuery.of(context).size.height / 5) *
                      ((promoIndex + 1) % 2 + 1))
                  .toDouble(),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

class PromoItemWidget extends StatelessWidget {
  const PromoItemWidget({Key key, this.promoItem, this.promoIndex})
      : super(key: key);

  final PromoItem promoItem;
  final int promoIndex;

  @override
  Widget build(BuildContext context) {
    int scale = (promoIndex + 1) % 2 + 1;
    return Container(
      height: ((MediaQuery.of(context).size.height / 5) * scale).toDouble(),
      child: CustomNetworkImageLoader(
          Tools.getImagePath(
              scale == 1 ? promoItem.imgThumb : promoItem.imgFull),
          Stack(
            children: [
              Center(
                child: Text(
                  promoItem.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MyDimens.titleNormal,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    promoItem.shop,
                    style: TextStyle(
                      fontSize: MyDimens.subtitleNormal,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          true),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({Key key, this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: (index + 1) * 100.0,
      color: Colors.teal[100 * (index % 9)],
      child: Text('Grid Item $index'),
    );
  }
}
