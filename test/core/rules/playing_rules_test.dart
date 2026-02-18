import 'package:flutter_test/flutter_test.dart';
import 'package:liujiatong/core/models/card.dart';
import 'package:liujiatong/core/rules/playing_rules.dart';

void main() {
  group('playing_rules', () {
    group('基本牌型', () {
      test('单张合法', () {
        final r = judgeAndTransformCards([14]);
        expect(r.type, CardType.single);
        expect(r.keyCard, 14);
      });

      test('对子合法', () {
        final r = judgeAndTransformCards([14, 14]);
        expect(r.type, CardType.pair);
        expect(r.keyCard, 14);
      });

      test('连对合法', () {
        final cards = [3, 3, 4, 4];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straightPairs);
        expect(r.keyCard, 4);
      });

      test('三张合法', () {
        final r = judgeAndTransformCards([10, 10, 10]);
        expect(r.type, CardType.triple);
        expect(r.keyCard, 10);
      });

      test('连三合法', () {
        final cards = [3, 3, 3, 4, 4, 4];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straightTriples);
        expect(r.keyCard, 4);
      });

      test('飞机合法', () {
        final cards = [3, 3, 3, 4, 4, 4, 5, 5, 6, 6];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.flight);
        expect(r.keyCard, 4);
      });

      test('顺子合法', () {
        final cards = [11, 10, 9, 8, 7]; // J-10-9-8-7
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straight);
        expect(r.keyCard, 11);
      });

      test('三带二合法', () {
        final r = judgeAndTransformCards([10, 10, 10, 9, 9]);
        expect(r.type, CardType.triplePair);
        expect(r.keyCard, 10);
      });

      test('普通炸弹合法', () {
        final r = judgeAndTransformCards([14, 14, 14, 14]);
        expect(r.type, CardType.normalBomb);
        expect(r.keyCard, 14);
      });

      test('小王炸弹合法', () {
        final r = judgeAndTransformCards([16, 16, 16, 16]);
        expect(r.type, CardType.blackJokerBomb);
        expect(r.keyCard, 16);
      });

      test('大王炸弹合法', () {
        final r = judgeAndTransformCards([17, 17, 17, 17]);
        expect(r.type, CardType.redJokerBomb);
        expect(r.keyCard, 17);
      });

      test('非法牌型', () {
        final r = judgeAndTransformCards([3, 5, 7]);
        expect(r.type, CardType.illegalType);
      });
    });

    group('对子测试', () {
      test('一张赖子与单张组成对子', () {
        final cards = [16, 14]; // 小王 + A
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.pair);
        // keyCard 为实际点数 A
        expect(r.keyCard, 14);
      });
    });

    group('连对测试', () {
      test('普通3连对合法', () {
        final cards = [7, 7, 8, 8, 9, 9]; // 77 88 99
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straightPairs);
        expect(r.keyCard, 9);
      });

      test('最小连对 AA22 合法', () {
        final cards = [14, 14, 15, 15]; // AA22
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straightPairs);
        // AA22 的 keyCard 约定为 1（见实现）
        expect(r.keyCard, 1);
      });

      test('一张赖子补成连对', () {
        // 77 88 + 小王 99-> 77 88 99
        final cards = [16, 9, 8, 8, 7, 7];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straightPairs);
        expect(r.keyCard, 9);
      });
    });

    group('三张测试', () {
      test('一张赖子与两张相同点数组成三张', () {
        final cards = [16, 14, 14]; // 小王 + A + A
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.triple);
        expect(r.keyCard, 14);
      });
    });

    group('连三测试', () {
      test('普通2连三合法', () {
        final cards = [7, 7, 7, 8, 8, 8]; // 777 888
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straightTriples);
        expect(r.keyCard, 8);
      });

      test('最小2连三合法', () {
        final cards = [14, 14, 14, 15, 15, 15];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straightTriples);
        expect(r.keyCard, 2);
      });
    });

    group('飞机测试', () {
      test('普通2连飞机合法', () {
        final cards = [7, 7, 7, 8, 8, 8, 5, 5, 6, 6];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.flight);
        expect(r.keyCard, 8);
      });

      test('普通3连飞机合法', () {
        final cards = [3, 3, 3, 4, 4, 4, 5, 5, 5, 8, 8, 9, 9, 10, 10];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.flight);
        expect(r.keyCard, 5);
      });

      test('单财神2连飞机合法', () {
        final cards = [3, 3, 3, 4, 4, 4, 5, 5, 6, 16];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.flight);
        expect(r.keyCard, 4);
      });

      test('单财神3连飞机合法', () {
        final cards = [3, 3, 3, 4, 4, 4, 5, 5, 5, 8, 8, 9, 9, 10, 16];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.flight);
        expect(r.keyCard, 5);
      });

      test('最小二连飞机合法', () {
        final cards = [14, 14, 14, 15, 15, 15, 3, 3, 4, 4];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.flight);
        expect(r.keyCard, 2);
      });

      test('KA2飞机不合法', () {
        final cards = [13, 13, 13, 14, 14, 14, 15, 15, 15, 3, 3, 4, 4, 5, 5];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.illegalType);
      });
    });

    group('顺子测试', () {
      test('普通5连顺合法', () {
        final cards = [11, 10, 9, 8, 7]; // J-10-9-8-7
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straight);
        expect(r.keyCard, 11);
      });

      test('一张赖子补最大点数成顺子', () {
        // 10 J Q K + 小王 = 10 J Q K A
        final cards = [16, 13, 12, 11, 10];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straight);
        // keyCard 为顺子最大牌 A(14)
        expect(r.keyCard, 14);
      });

      test('一张赖子补中间点数成顺子', () {
        // 10 J Q K + 小王 = 10 J Q K A
        final cards = [14, 16, 12, 11, 10];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straight);
        // keyCard 为顺子最大牌 A(14)
        expect(r.keyCard, 14);
      });

      test('最小顺子 A2345 合法', () {
        final cards = [14, 5, 4, 3, 2]; // A2345
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.straight);
        expect(r.keyCard, 5);
      });
    });

    group('三带二测试', () {
      test('普通三带二合法', () {
        final cards = [10, 10, 10, 9, 9];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.triplePair);
        expect(r.keyCard, 10);
      });

      test('一张赖子补成三带二', () {
        // 10 10 10 + 9 + 小王 -> 10 10 10 9 9
        final cards = [16, 9, 10, 10, 10];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.triplePair);
        expect(r.keyCard, 10);
      });
    });

    group('炸弹测试', () {
      test('普通炸弹合法', () {
        final cards = [14, 14, 14, 14];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.normalBomb);
        expect(r.keyCard, 14);
      });

      test('小王炸弹合法', () {
        final cards = [16, 16, 16, 16];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.blackJokerBomb);
        expect(r.keyCard, 16);
      });

      test('大王炸弹合法', () {
        final cards = [17, 17, 17, 17];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.redJokerBomb);
        expect(r.keyCard, 17);
      });

      test('小王炸混合大王不合法', () {
        final cards = [16, 16, 16, 16, 17];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.illegalType);
      });

      test('大王炸混合小王不合法', () {
        final cards = [17, 17, 17, 17, 16];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.illegalType);
      });

      test('混合大小王视为2炸-4张', () {
        final cards = [16, 16, 17, 17];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.normalBomb);
        expect(r.keyCard, 15); // 视为4张2
      });

      test('混合大小王视为2炸-5张', () {
        final cards = [16, 16, 17, 17, 17];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.normalBomb);
        expect(r.keyCard, 15); // 视为5张2
      });

      test('普通炸弹之间比较：5 张炸弹大于 4 张炸弹', () {
        final last = [13, 13, 13, 13]; // 4 张 K
        final next = [3, 3, 3, 3, 3]; // 5 张 3
        last.sort((a, b) => b.compareTo(a));
        next.sort((a, b) => b.compareTo(a));
        final ok = ifNotFirstInputLegal(next, last);
        expect(ok, isTrue);
      });

      test('普通炸弹之间比较：4 张 A 大于 4 张 K', () {
        final last = [13, 13, 13, 13]; // 4 张 K
        final next = [14, 14, 14, 14]; // 4 张 A
        last.sort((a, b) => b.compareTo(a));
        next.sort((a, b) => b.compareTo(a));
        final ok = ifNotFirstInputLegal(next, last);
        expect(ok, isTrue);
      });

      test('小王炸能压 4~8 张普通炸弹', () {
        final last = [15, 15, 15, 15, 15, 15, 15, 15]; // 8 张 2
        final next = [16, 16, 16, 16]; // 4 张小王
        last.sort((a, b) => b.compareTo(a));
        next.sort((a, b) => b.compareTo(a));
        final ok = ifNotFirstInputLegal(next, last);
        expect(ok, isTrue);
      });

      test('9 张普通炸弹可以压小王炸弹', () {
        final last = [17, 17, 17, 17]; // 小王炸弹
        final next = List<int>.filled(9, 3); // 9 张 A
        last.sort((a, b) => b.compareTo(a));
        next.sort((a, b) => b.compareTo(a));
        final ok = ifNotFirstInputLegal(next, last);
        expect(ok, isTrue);
      });

      test('大王炸弹能压 4~8 张普通炸弹', () {
        final last = List<int>.filled(8, 15); // 8 张 2
        final next = [17, 17, 17, 17]; // 4 张大王
        last.sort((a, b) => b.compareTo(a));
        next.sort((a, b) => b.compareTo(a));
        final ok = ifNotFirstInputLegal(next, last);
        expect(ok, isTrue);
      });

      test('9 张普通炸弹可以压大王炸弹', () {
        final last = [17, 17, 17, 17]; // 大王炸弹
        final next = List<int>.filled(9, 14); // 9 张 A
        last.sort((a, b) => b.compareTo(a));
        next.sort((a, b) => b.compareTo(a));
        final ok = ifNotFirstInputLegal(next, last);
        expect(ok, isTrue);
      });

      test('大王炸弹可以压小王炸弹', () {
        final last = [16, 16, 16, 16]; // 小王炸弹
        final next = [17, 17, 17, 17]; // 大王炸弹
        last.sort((a, b) => b.compareTo(a));
        next.sort((a, b) => b.compareTo(a));
        final ok = ifNotFirstInputLegal(next, last);
        expect(ok, isTrue);
      });

      test('小王炸弹不能压大王炸弹', () {
        final last = [17, 17, 17, 17]; // 大王炸弹
        final next = [16, 16, 16, 16]; // 小王炸弹
        last.sort((a, b) => b.compareTo(a));
        next.sort((a, b) => b.compareTo(a));
        final ok = ifNotFirstInputLegal(next, last);
        expect(ok, isFalse);
      });

      test('带赖子的普通炸弹 keyCard 为普通牌点数', () {
        // 888 + 两张小王，按规则应视为 5 张 8 的炸弹，keyCard = 8
        final cards = [16, 16, 8, 8, 8];
        cards.sort((a, b) => b.compareTo(a));
        final r = judgeAndTransformCards(cards);
        expect(r.type, CardType.normalBomb);
        expect(r.keyCard, 8);
      });
    });

    test('firstInputLegal', () {
      expect(firstInputLegal([14]), true);
      expect(firstInputLegal([3, 5, 7]), false);
    });

    test('validateUserInput 首出单张', () {
      final hand = [Card(Suits.spade, 14)];
      final r = validateUserInput([14], hand, null);
      expect(r.legal, true);
      expect(r.score, 0);
    });

    test('validateUserInput 跳过', () {
      final r = validateUserInput([0], [], [Card(Suits.spade, 5)]);
      expect(r.legal, true);
      final r2 = validateUserInput([0], [], null);
      expect(r2.legal, false);
    });

    test('validateUserSelectedCards', () {
      final selected = [Card(Suits.spade, 14), Card(Suits.heart, 14)];
      final hand = [Card(Suits.spade, 14), Card(Suits.heart, 14), Card(Suits.club, 5)];
      expect(validateUserSelectedCards(selected, hand, null), true);
    });

    test('ifEnoughCard 手牌不足返回 false', () {
      final hand = [Card(Suits.spade, 14)];
      final result = ifEnoughCard([14, 14], hand);
      expect(result.enough, false);
      expect(result.score, 0);
    });

    test('validateUserInput 返回正确分数', () {
      final hand = [
        Card(Suits.spade, 5),
        Card(Suits.heart, 5),
        Card(Suits.club, 10),
      ];
      final r = validateUserInput([5, 10], hand, null);
      expect(r.legal, false); // 两张不构成合法牌型
      final r2 = validateUserInput([5], hand, null);
      expect(r2.legal, true);
      expect(r2.score, 5);
    });

    group('validateUserSelectedCards 牌型组合覆盖', () {
      // 使用固定的牌值来代表九种基本牌型（不含赖子），方便做 9x9 组合测试。
      // 每种牌型准备一组「上家」示例牌和一组「当前玩家」示例牌（通常更大）。
      List<Card> makeCards(List<int> values) =>
          values.map((v) => Card(Suits.spade, v)).toList();

      final scenarios = <Map<String, Object>>[
        {
          'name': '单张',
          'last': [5],
          'current': [6],
        },
        {
          'name': '对子',
          'last': [5, 5],
          'current': [6, 6],
        },
        {
          'name': '三张',
          'last': [5, 5, 5],
          'current': [6, 6, 6],
        },
        {
          'name': '三带二',
          // 555+33 与 666+33
          'last': [5, 5, 5, 3, 3],
          'current': [6, 6, 6, 3, 3],
        },
        {
          'name': '顺子',
          // 34567 与 45678
          'last': [7, 6, 5, 4, 3],
          'current': [8, 7, 6, 5, 4],
        },
        {
          'name': '连对',
          // 33 44 与 44 55
          'last': [4, 4, 3, 3],
          'current': [5, 5, 4, 4],
        },
        {
          'name': '连三',
          // 333 444 与 444 555
          'last': [4, 4, 4, 3, 3, 3],
          'current': [5, 5, 5, 4, 4, 4],
        },
        {
          'name': '飞机',
          // 使用与上文测试一致的无赖子飞机形态
          // last: 44 55 6 6 6 7 7 7
          // current: 55 66 7 7 7 8 8 8
          'last': [7, 7, 7, 6, 6, 6, 5, 5, 4, 4],
          'current': [8, 8, 8, 7, 7, 7, 6, 6, 5, 5],
        },
        {
          'name': '炸弹',
          // 普通炸弹：4 张 9，5 张 10
          'last': [9, 9, 9, 9],
          'current': [10, 10, 10, 10, 10],
        },
      ];

      for (final last in scenarios) {
        final lastName = last['name'] as String;
        final lastValues = (last['last'] as List<int>);
        for (final cur in scenarios) {
          final curName = cur['name'] as String;
          final curValues = (cur['current'] as List<int>);

          test('上家: $lastName, 当前: $curName', () {
            final lastCards = makeCards(lastValues);
            final currentCards = makeCards(curValues);
            // 手牌只需包含当前要出的牌即可满足数量校验
            final userHand = List<Card>.from(currentCards);

            final expected = validateUserInput(
              currentCards.map((c) => c.value).toList(),
              userHand,
              lastCards,
            ).legal;

            final actual =
                validateUserSelectedCards(currentCards, userHand, lastCards);
            expect(actual, expected);
          });
        }
      }
    });
  });
}
